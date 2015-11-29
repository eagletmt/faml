#include <ruby.h>
#include <ruby/encoding.h>
#include <ruby/version.h>
#include "houdini.h"
#include <algorithm>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <vector>

#if (RUBY_API_VERSION_MAJOR > 2) || (RUBY_API_VERSION_MAJOR == 2 && RUBY_API_VERSION_MINOR >= 1)
/* define nothing */
#else
# define RARRAY_AREF(a, i) RARRAY_PTR(a)[i]
# define rb_ary_new_capa rb_ary_new2
#endif

#define FOREACH_FUNC(func) reinterpret_cast<int (*)(ANYARGS)>(func)

VALUE rb_mAttributeBuilder;
static ID id_flatten;
static ID id_hyphen;

static inline std::string
string_from_value(VALUE v)
{
  return std::string(RSTRING_PTR(v), RSTRING_LEN(v));
}

enum attribute_value_type
{
  ATTRIBUTE_TYPE_TRUE,
  ATTRIBUTE_TYPE_FALSE,
  ATTRIBUTE_TYPE_VALUE,
};

struct attribute_value
{
  attribute_value_type type_;
  std::string str_;

  attribute_value(attribute_value_type type) : type_(type) {}
  attribute_value(const char *cstr, long len) : type_(ATTRIBUTE_TYPE_VALUE), str_(cstr, len) {}
  attribute_value(const std::string& str) : type_(ATTRIBUTE_TYPE_VALUE), str_(str) {}

  static attribute_value from_value(VALUE value)
  {
    if (RB_TYPE_P(value, T_TRUE)) {
      return attribute_value(ATTRIBUTE_TYPE_TRUE);
    } else if (!RTEST(value)) {
      return attribute_value(ATTRIBUTE_TYPE_FALSE);
    } else {
      value = rb_convert_type(value, T_STRING, "String", "to_s");
      return attribute_value(string_from_value(value));
    }
  }
};

typedef std::map<std::string, attribute_value> attributes_type;

struct attribute_holder
{
  std::vector<attribute_value> ids_, classes_;
  attributes_type m_;

  void insert(const std::string& key, const attribute_value& value)
  {
    const std::pair<attributes_type::iterator, bool> r = m_.insert(std::make_pair(key, value));
    if (!r.second) {
      r.first->second = value;
    }
  }
};

static VALUE
to_value(const attributes_type& m)
{
  VALUE h = rb_hash_new();
  for (attributes_type::const_iterator it = m.begin(); it != m.end(); ++it) {
    VALUE k = rb_enc_str_new(it->first.data(), it->first.size(), rb_utf8_encoding());
    VALUE v = Qnil;
    switch (it->second.type_) {
      case ATTRIBUTE_TYPE_TRUE:
        v = Qtrue;
        break;
      case ATTRIBUTE_TYPE_FALSE:
        v = Qnil;
        break;
      case ATTRIBUTE_TYPE_VALUE:
        v = rb_enc_str_new(it->second.str_.data(), it->second.str_.size(), rb_utf8_encoding());
        break;
    }
    rb_hash_aset(h, k, v);
  }
  return h;
}

static void
concat_array_attribute(std::vector<attribute_value>& ary, VALUE value)
{
  if (RB_TYPE_P(value, T_ARRAY)) {
    value = rb_funcall(value, id_flatten, 0);
  } else {
    value = rb_Array(value);
  }
  const long len = RARRAY_LEN(value);
  for (long i = 0; i < len; i++) {
    ary.push_back(attribute_value::from_value(RARRAY_AREF(value, i)));
  }
}

struct normalize_data_i2_arg {
  VALUE key, normalized;
};

static VALUE
substitute_underscores(VALUE str)
{
  int frozen;
  long i, len;

  /* gsub('_', '-') */
  Check_Type(str, T_STRING);
  len = RSTRING_LEN(str);
  frozen = OBJ_FROZEN(str);
  for (i = 0; i < len; i++) {
    if (RSTRING_PTR(str)[i] == '_') {
      if (frozen) {
        str = rb_str_dup(str);
        frozen = 0;
      }
      rb_str_update(str, i, 1, rb_const_get(rb_mAttributeBuilder, id_hyphen));
    }
  }

  return str;
}

static int
normalize_data_i2(VALUE key, VALUE value, VALUE ptr)
{
  struct normalize_data_i2_arg *arg = (struct normalize_data_i2_arg *)ptr;
  VALUE k = rb_str_dup(arg->key);

  rb_str_cat(k, "-", 1);
  rb_str_append(k, key);
  rb_hash_aset(arg->normalized, k, value);
  return ST_CONTINUE;
}

static VALUE normalize_data(VALUE data);

static int
normalize_data_i(VALUE key, VALUE value, VALUE normalized)
{
  key = rb_convert_type(key, T_STRING, "String", "to_s");
  key = substitute_underscores(key);

  if (RB_TYPE_P(value, T_HASH)) {
    struct normalize_data_i2_arg arg;
    arg.key = key;
    arg.normalized = normalized;
    rb_hash_foreach(normalize_data(value), FOREACH_FUNC(normalize_data_i2), reinterpret_cast<VALUE>(&arg));
  } else if (RB_TYPE_P(value, T_TRUE) || !RTEST(value)) {
    /* Keep Qtrue and falsey value */
    rb_hash_aset(normalized, key, value);
  } else {
    rb_hash_aset(normalized, key, rb_convert_type(value, T_STRING, "String", "to_s"));
  }
  return ST_CONTINUE;
}

static VALUE
normalize_data(VALUE data)
{
  VALUE normalized;

  Check_Type(data, T_HASH);
  normalized = rb_hash_new();
  rb_hash_foreach(data, FOREACH_FUNC(normalize_data_i), normalized);
  return normalized;
}

static int
put_data_attribute(VALUE key, VALUE val, VALUE arg)
{
  attribute_holder *attributes = reinterpret_cast<attribute_holder *>(arg);
  attributes->insert("data-" + string_from_value(key), attribute_value::from_value(val));
  return ST_CONTINUE;
}

static int
merge_one_i(VALUE key, VALUE value, VALUE arg)
{
  attribute_holder *attributes = reinterpret_cast<attribute_holder *>(arg);

  key = rb_convert_type(key, T_STRING, "String", "to_s");
  const std::string key_ = string_from_value(key);
  if (key_ == "class") {
    concat_array_attribute(attributes->classes_, value);
  } else if (key_ == "id") {
    concat_array_attribute(attributes->ids_, value);
  } else if (key_ == "data" && RB_TYPE_P(value, T_HASH)) {
    VALUE data = normalize_data(value);
    rb_hash_foreach(data, FOREACH_FUNC(put_data_attribute), arg);
  } else {
    attributes->insert(key_, attribute_value::from_value(value));
  }
  return ST_CONTINUE;
}

static void
merge_one(attribute_holder& attributes, VALUE h)
{
  Check_Type(h, T_HASH);
  rb_hash_foreach(h, FOREACH_FUNC(merge_one_i), reinterpret_cast<VALUE>(&attributes));
}

static void
join_class_attribute(attribute_holder& attributes)
{
  const std::vector<attribute_value>& classes = attributes.classes_;
  std::vector<std::string> ary;

  for (std::vector<attribute_value>::const_iterator it = classes.begin(); it != classes.end(); ++it) {
    switch (it->type_) {
      case ATTRIBUTE_TYPE_FALSE:
        break;
      case ATTRIBUTE_TYPE_TRUE:
        ary.push_back("true");
        break;
      case ATTRIBUTE_TYPE_VALUE:
        size_t prev = 0, pos;
        while ((pos = it->str_.find_first_of(' ', prev)) != std::string::npos) {
          if (pos != prev) {
            ary.push_back(std::string(it->str_, prev, pos - prev));
          }
          prev = pos+1;
        }
        ary.push_back(std::string(it->str_, prev, it->str_.size() - prev));
        break;
    }
  }
  if (ary.empty()) {
    return;
  }

  std::sort(ary.begin(), ary.end());
  ary.erase(std::unique(ary.begin(), ary.end()), ary.end());
  std::ostringstream oss;
  for (std::vector<std::string>::const_iterator it = ary.begin(); it != ary.end(); ++it) {
    if (it != ary.begin()) {
      oss << ' ';
    }
    oss << *it;
  }
  attributes.insert("class", attribute_value(oss.str()));
}

static void
join_id_attribute(attribute_holder& attributes)
{
  const std::vector<attribute_value>& ids = attributes.ids_;
  std::ostringstream oss;

  for (std::vector<attribute_value>::const_iterator it = ids.begin(); it != ids.end(); ++it) {
    switch (it->type_) {
      case ATTRIBUTE_TYPE_FALSE:
        break;
      case ATTRIBUTE_TYPE_TRUE:
        if (!oss.str().empty()) {
          oss << '_';
        }
        oss << "true";
        break;
      case ATTRIBUTE_TYPE_VALUE:
        if (!oss.str().empty()) {
          oss << '_';
        }
        oss << it->str_;
        break;
    }
  }
  if (oss.str().empty()) {
    return;
  }

  attributes.insert("id", attribute_value(oss.str()));
}

static void
delete_falsey_values(attributes_type& m)
{
  for (attributes_type::iterator it = m.begin(); it != m.end();) {
    if (it->second.type_ == ATTRIBUTE_TYPE_FALSE) {
      attributes_type::iterator jt = it;
      ++it;
      m.erase(jt);
    } else {
      ++it;
    }
  }
}

static attributes_type
merge(VALUE object_ref, int argc, VALUE *argv)
{
  int i;
  attribute_holder attributes;

  for (i = 0; i < argc; i++) {
    merge_one(attributes, argv[i]);
  }
  if (!NIL_P(object_ref)) {
    merge_one(attributes, object_ref);
  }

  join_class_attribute(attributes);
  join_id_attribute(attributes);
  delete_falsey_values(attributes.m_);

  return attributes.m_;
}

static void
put_attribute(std::ostringstream& oss, const std::string& attr_quote, const std::string& key, const std::string& value)
{
  oss << " " << key << "=" << attr_quote;

  gh_buf ob = GH_BUF_INIT;
  if (houdini_escape_html0(&ob, (const uint8_t *)value.data(), value.size(), 0)) {
    oss << std::string(ob.ptr, ob.size);
    gh_buf_free(&ob);
  } else {
    oss << value;
  }
  oss << attr_quote;
}

static void
build_attribute(std::ostringstream& oss, const std::string& attr_quote, int is_html, const std::string& key, const attribute_value& value)
{
  if (value.type_ == ATTRIBUTE_TYPE_TRUE) {
    if (is_html) {
      oss << ' ' << key;
    } else {
      put_attribute(oss, attr_quote, key, key);
    }
  } else {
    put_attribute(oss, attr_quote, key, value.str_);
  }
}

static VALUE
m_build(int argc, VALUE *argv, RB_UNUSED_VAR(VALUE self))
{
  VALUE object_ref;
  int is_html;

  rb_check_arity(argc, 3, UNLIMITED_ARGUMENTS);
  Check_Type(argv[0], T_STRING);
  const std::string attr_quote = string_from_value(argv[0]);
  is_html = RTEST(argv[1]);
  object_ref = argv[2];
  const attributes_type attributes = merge(object_ref, argc-3, argv+3);

  std::ostringstream oss;
  for (attributes_type::const_iterator it = attributes.begin(); it != attributes.end(); ++it) {
    build_attribute(oss, attr_quote, is_html, it->first, it->second);
  }

  return rb_enc_str_new(oss.str().data(), oss.str().size(), rb_utf8_encoding());
}

static VALUE
m_normalize_data(RB_UNUSED_VAR(VALUE self), VALUE data)
{
  return normalize_data(data);
}

static VALUE
m_merge(int argc, VALUE *argv, RB_UNUSED_VAR(VALUE self))
{
  rb_check_arity(argc, 1, UNLIMITED_ARGUMENTS);
  return to_value(merge(argv[0], argc-1, argv+1));
}

extern "C" {
void
Init_attribute_builder(void)
{
  VALUE mFaml = rb_define_module("Faml");
  rb_mAttributeBuilder = rb_define_module_under(mFaml, "AttributeBuilder");
  rb_define_singleton_method(rb_mAttributeBuilder, "build", RUBY_METHOD_FUNC(m_build), -1);
  rb_define_singleton_method(rb_mAttributeBuilder, "normalize_data", RUBY_METHOD_FUNC(m_normalize_data), 1);
  rb_define_singleton_method(rb_mAttributeBuilder, "merge", RUBY_METHOD_FUNC(m_merge), -1);

  id_flatten = rb_intern("flatten");
  id_hyphen = rb_intern("HYPHEN");
  rb_const_set(rb_mAttributeBuilder, id_hyphen, rb_obj_freeze(rb_str_new_cstr("-")));
}
};

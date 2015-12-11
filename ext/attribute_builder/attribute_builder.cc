#include <ruby.h>
#include <ruby/version.h>
#include "houdini.h"
#include <algorithm>
#include <map>
#include <string>
#include <vector>

/* faml requires Ruby >= 2.0.0 */
/* RARRAY_AREF() is available since Ruby 2.1 */
#if RUBY_API_VERSION_MAJOR == 2 && RUBY_API_VERSION_MINOR < 1
#define RARRAY_AREF(a, i) RARRAY_PTR(a)[i]
#endif
/* rb_utf8_str_new() is available since Ruby 2.2 */
#if RUBY_API_VERSION_MAJOR == 2 && RUBY_API_VERSION_MINOR < 2
#include <ruby/encoding.h>
#define rb_utf8_str_new(ptr, len) rb_enc_str_new(ptr, len, rb_utf8_encoding())
#endif

#define FOREACH_FUNC(func) reinterpret_cast<int (*)(ANYARGS)>(func)

VALUE rb_mAttributeBuilder;
static ID id_flatten;

static inline std::string string_from_value(VALUE v) {
  return std::string(RSTRING_PTR(v), RSTRING_LEN(v));
}

enum attribute_value_type {
  ATTRIBUTE_TYPE_TRUE,
  ATTRIBUTE_TYPE_FALSE,
  ATTRIBUTE_TYPE_VALUE,
};

struct attribute_value {
  attribute_value_type type_;
  std::string str_;

  attribute_value(attribute_value_type type) : type_(type) {}
  attribute_value(const char* cstr, long len)
      : type_(ATTRIBUTE_TYPE_VALUE), str_(cstr, len) {}
  attribute_value(const std::string& str)
      : type_(ATTRIBUTE_TYPE_VALUE), str_(str) {}

  static attribute_value from_value(VALUE value) {
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

void upsert_attribute(attributes_type& m, const std::string& key,
                      const attribute_value& value) {
  const std::pair<attributes_type::iterator, bool> r =
      m.insert(std::make_pair(key, value));
  if (!r.second) {
    r.first->second = value;
  }
}

struct attribute_holder {
  std::vector<attribute_value> ids_, classes_;
  attributes_type m_;

  inline void upsert(const std::string& key, const attribute_value& value) {
    return upsert_attribute(m_, key, value);
  }
};

static VALUE to_value(const attributes_type& m) {
  VALUE h = rb_hash_new();
  for (attributes_type::const_iterator it = m.begin(); it != m.end(); ++it) {
    VALUE k = rb_utf8_str_new(it->first.data(), it->first.size());
    VALUE v = Qnil;
    switch (it->second.type_) {
      case ATTRIBUTE_TYPE_TRUE:
        v = Qtrue;
        break;
      case ATTRIBUTE_TYPE_FALSE:
        v = Qnil;
        break;
      case ATTRIBUTE_TYPE_VALUE:
        v = rb_utf8_str_new(it->second.str_.data(), it->second.str_.size());
        break;
    }
    rb_hash_aset(h, k, v);
  }
  return h;
}

static void concat_array_attribute(std::vector<attribute_value>& ary,
                                   VALUE value) {
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

static attributes_type normalize_data(VALUE data);

static int normalize_data_i(VALUE key, VALUE value, VALUE arg) {
  attributes_type* normalized = reinterpret_cast<attributes_type*>(arg);
  key = rb_convert_type(key, T_STRING, "String", "to_s");
  std::string key_ = string_from_value(key);
  std::replace(key_.begin(), key_.end(), '_', '-');

  if (RB_TYPE_P(value, T_HASH)) {
    const attributes_type sub = normalize_data(value);
    for (attributes_type::const_iterator it = sub.begin(); it != sub.end();
         ++it) {
      upsert_attribute(*normalized, key_ + "-" + it->first, it->second);
    }
  } else {
    upsert_attribute(*normalized, key_, attribute_value::from_value(value));
  }
  return ST_CONTINUE;
}

static attributes_type normalize_data(VALUE data) {
  Check_Type(data, T_HASH);
  attributes_type m;
  rb_hash_foreach(data, FOREACH_FUNC(normalize_data_i),
                  reinterpret_cast<VALUE>(&m));
  return m;
}

static int merge_one_i(VALUE key, VALUE value, VALUE arg) {
  attribute_holder* attributes = reinterpret_cast<attribute_holder*>(arg);

  key = rb_convert_type(key, T_STRING, "String", "to_s");
  const std::string key_ = string_from_value(key);
  if (key_ == "class") {
    concat_array_attribute(attributes->classes_, value);
  } else if (key_ == "id") {
    concat_array_attribute(attributes->ids_, value);
  } else if (key_ == "data" && RB_TYPE_P(value, T_HASH)) {
    const attributes_type data = normalize_data(value);
    for (attributes_type::const_iterator it = data.begin(); it != data.end();
         ++it) {
      attributes->upsert("data-" + it->first, it->second);
    }
  } else {
    attributes->upsert(key_, attribute_value::from_value(value));
  }
  return ST_CONTINUE;
}

static void merge_one(attribute_holder& attributes, VALUE h) {
  Check_Type(h, T_HASH);
  rb_hash_foreach(h, FOREACH_FUNC(merge_one_i),
                  reinterpret_cast<VALUE>(&attributes));
}

static void join_class_attribute(attribute_holder& attributes) {
  const std::vector<attribute_value>& classes = attributes.classes_;
  std::vector<std::string> ary;

  for (std::vector<attribute_value>::const_iterator it = classes.begin();
       it != classes.end(); ++it) {
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
          prev = pos + 1;
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
  std::string buf;
  for (std::vector<std::string>::const_iterator it = ary.begin();
       it != ary.end(); ++it) {
    if (it != ary.begin()) {
      buf.push_back(' ');
    }
    buf.append(*it);
  }
  attributes.upsert("class", attribute_value(buf));
}

static void join_id_attribute(attribute_holder& attributes) {
  const std::vector<attribute_value>& ids = attributes.ids_;
  std::string buf;
  bool first = true;

  for (std::vector<attribute_value>::const_iterator it = ids.begin();
       it != ids.end(); ++it) {
    switch (it->type_) {
      case ATTRIBUTE_TYPE_FALSE:
        break;
      case ATTRIBUTE_TYPE_TRUE:
        if (!first) {
          buf.push_back('_');
        }
        buf.append("true");
        first = false;
        break;
      case ATTRIBUTE_TYPE_VALUE:
        if (!first) {
          buf.push_back('_');
        }
        buf.append(it->str_);
        first = false;
        break;
    }
  }
  if (first) {
    return;
  }

  attributes.upsert("id", attribute_value(buf));
}

static void delete_falsey_values(attributes_type& m) {
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

static attributes_type merge(VALUE object_ref, int argc, VALUE* argv) {
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

static void put_attribute(std::string& buf,
                          const std::string& attr_quote, const std::string& key,
                          const std::string& value) {
  buf.append(" ").append(key).append("=").append(attr_quote);

  gh_buf ob = GH_BUF_INIT;
  if (houdini_escape_html0(&ob, (const uint8_t*)value.data(), value.size(),
                           0)) {
    buf.append(std::string(ob.ptr, ob.size));
    gh_buf_free(&ob);
  } else {
    buf.append(value);
  }
  buf.append(attr_quote);
}

static void build_attribute(std::string& buf,
                            const std::string& attr_quote, int is_html,
                            const std::string& key,
                            const attribute_value& value) {
  if (value.type_ == ATTRIBUTE_TYPE_TRUE) {
    if (is_html) {
      buf.push_back(' ');
      buf.append(key);
    } else {
      put_attribute(buf, attr_quote, key, key);
    }
  } else {
    put_attribute(buf, attr_quote, key, value.str_);
  }
}

static VALUE m_build(int argc, VALUE* argv, RB_UNUSED_VAR(VALUE self)) {
  VALUE object_ref;
  int is_html;

  rb_check_arity(argc, 3, UNLIMITED_ARGUMENTS);
  Check_Type(argv[0], T_STRING);
  const std::string attr_quote = string_from_value(argv[0]);
  is_html = RTEST(argv[1]);
  object_ref = argv[2];
  const attributes_type attributes = merge(object_ref, argc - 3, argv + 3);

  std::string buf;
  for (attributes_type::const_iterator it = attributes.begin();
       it != attributes.end(); ++it) {
    build_attribute(buf, attr_quote, is_html, it->first, it->second);
  }

  return rb_utf8_str_new(buf.data(), buf.size());
}

static VALUE m_normalize_data(RB_UNUSED_VAR(VALUE self), VALUE data) {
  return to_value(normalize_data(data));
}

static VALUE m_merge(int argc, VALUE* argv, RB_UNUSED_VAR(VALUE self)) {
  rb_check_arity(argc, 1, UNLIMITED_ARGUMENTS);
  return to_value(merge(argv[0], argc - 1, argv + 1));
}

extern "C" {
void Init_attribute_builder(void) {
  VALUE mFaml = rb_define_module("Faml");
  rb_mAttributeBuilder = rb_define_module_under(mFaml, "AttributeBuilder");
  rb_define_singleton_method(rb_mAttributeBuilder, "build",
                             RUBY_METHOD_FUNC(m_build), -1);
  rb_define_singleton_method(rb_mAttributeBuilder, "normalize_data",
                             RUBY_METHOD_FUNC(m_normalize_data), 1);
  rb_define_singleton_method(rb_mAttributeBuilder, "merge",
                             RUBY_METHOD_FUNC(m_merge), -1);

  id_flatten = rb_intern("flatten");
}
};

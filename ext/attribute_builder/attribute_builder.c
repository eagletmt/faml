#include <ruby.h>
#include <ruby/version.h>

#if (RUBY_API_VERSION_MAJOR > 2) || (RUBY_API_VERSION_MAJOR == 2 && RUBY_API_VERSION_MINOR >= 1)
/* define nothing */
#else
# define RARRAY_AREF(a, i) RARRAY_PTR(a)[i]
# define rb_ary_new_capa rb_ary_new2
#endif

VALUE rb_mAttributeBuilder;
static ID id_keys, id_sort_bang, id_uniq_bang, id_merge_bang, id_temple, id_utils, id_escape_html, id_gsub, id_to_s;
  /* borrowed from https://github.com/rails/rails/blob/4-2-stable/actionview/lib/action_view/helpers/tag_helper.rb#L14-L19 */
static const char *boolean_attributes[] = {
  "disabled",
  "readonly",
  "multiple",
  "checked",
  "autobuffer",
  "autoplay",
  "controls",
  "loop",
  "selected",
  "hidden",
  "scoped",
  "async",
  "defer",
  "reversed",
  "ismap",
  "seamless",
  "muted",
  "required",
  "autofocus",
  "novalidate",
  "formnovalidate",
  "open",
  "pubdate",
  "itemscope",
  "allowfullscreen",
  "default",
  "inert",
  "sortable",
  "truespeed",
  "typemustmatch",
};

static int
boolean_attribute_p(const char *key)
{
  unsigned i;

  for (i = 0; i < sizeof(boolean_attributes)/sizeof(boolean_attributes[0]); i++) {
    if (strcmp(boolean_attributes[i], key) == 0) {
      return 1;
    }
  }
  return 0;
}

static void
concat_array_attribute(VALUE attributes, VALUE hash, VALUE key)
{
  VALUE v;

  Check_Type(hash, T_HASH);
  v = rb_hash_delete(hash, key);
  if (!NIL_P(v)) {
    VALUE ary;

    v = rb_Array(v);
    ary = rb_hash_lookup(attributes, key);
    Check_Type(ary, T_ARRAY);
    rb_ary_concat(ary, v);
  }
}

static int
stringify_keys_i(VALUE key, VALUE value, VALUE arg)
{
  key = rb_funcall(key, id_to_s, 0);
  rb_hash_aset(arg, key, value);
  return ST_CONTINUE;
}

static VALUE
stringify_keys(VALUE hash)
{
  VALUE h = rb_hash_new();
  rb_hash_foreach(hash, stringify_keys_i, h);
  return h;
}

struct normalize_data_i2_arg {
  VALUE key, normalized;
};

static int
normalize_data_i2(VALUE key, VALUE value, VALUE ptr)
{
  struct normalize_data_i2_arg *arg = (struct normalize_data_i2_arg *)ptr;
  VALUE k = rb_funcall(arg->key, id_to_s, 0);

  k = rb_funcall(k, id_gsub, 2, rb_str_new_cstr("_"), rb_str_new_cstr("-"));
  rb_str_cat(k, "-", 1);
  rb_str_append(k, key);
  rb_hash_aset(arg->normalized, k, value);
  return ST_CONTINUE;
}

static VALUE normalize_data(VALUE data);

static int
normalize_data_i(VALUE key, VALUE value, VALUE normalized)
{
  if (RB_TYPE_P(value, T_HASH)) {
    struct normalize_data_i2_arg arg;
    arg.key = key;
    arg.normalized = normalized;
    rb_hash_foreach(normalize_data(value), normalize_data_i2, (VALUE)(&arg));
  } else {
    key = rb_funcall(key, id_to_s, 0);
    key = rb_funcall(key, id_gsub, 2, rb_str_new_cstr("_"), rb_str_new_cstr("-"));
    rb_hash_aset(normalized, key, value);
  }
  return ST_CONTINUE;
}

static VALUE
normalize_data(VALUE data)
{
  VALUE normalized;

  Check_Type(data, T_HASH);
  normalized = rb_hash_new();
  rb_hash_foreach(data, normalize_data_i, normalized);
  return normalized;
}

static void
normalize(VALUE hash)
{
  VALUE keys = rb_funcall(hash, id_keys, 0);
  const long len = RARRAY_LEN(keys);
  long i;
  for (i = 0; i < len; i++) {
    VALUE key = RARRAY_AREF(keys, i);
    const char *key_cstr = StringValueCStr(key);
    VALUE value = rb_hash_lookup(hash, key);
    if (RB_TYPE_P(value, T_HASH) && strcmp(key_cstr, "data") == 0) {
      VALUE data, data_keys;
      long data_len, j;

      rb_hash_delete(hash, key);
      data = normalize_data(value);
      data_keys = rb_funcall(data, id_keys, 0);
      rb_funcall(data_keys, id_sort_bang, 0);
      data_len = RARRAY_LEN(data_keys);
      for (j = 0; j < data_len; j++) {
        VALUE data_key = RARRAY_AREF(data_keys, j);
        VALUE k = rb_str_buf_new(5 + RSTRING_LEN(data_key));
        rb_str_buf_cat(k, "data-", 5);
        rb_str_buf_append(k, data_key);
        rb_hash_aset(hash, k, rb_hash_lookup(data, data_key));
      }
    } else if (!(RB_TYPE_P(value, T_TRUE) || RB_TYPE_P(value, T_FALSE) || NIL_P(value))) {
      rb_hash_aset(hash, key, rb_funcall(value, id_to_s, 0));
    }
  }
}

static void
merge(VALUE attributes, int argc, VALUE *argv)
{
  int i;

  for (i = 0; i < argc; i++) {
    VALUE h;

    Check_Type(argv[i], T_HASH);
    h = stringify_keys(argv[i]);
    concat_array_attribute(attributes, h, rb_str_new_cstr("class"));
    concat_array_attribute(attributes, h, rb_str_new_cstr("id"));
    normalize(h);
    rb_funcall(attributes, id_merge_bang, 1, h);
  }
}

static VALUE
put_attribute(VALUE attr_quote, VALUE key, VALUE value)
{
  VALUE utils_class, str;
  long len;

  value = rb_funcall(value, id_to_s, 0);
  utils_class = rb_const_get(rb_const_get(rb_cObject, id_temple), id_utils);
  value = rb_funcall(utils_class, id_escape_html, 1, value);

  len = 2 + 2*RSTRING_LEN(attr_quote) + RSTRING_LEN(key) + RSTRING_LEN(value);
  str = rb_str_buf_new(len);
  rb_str_buf_cat(str, " ", 1);
  rb_str_buf_append(str, key);
  rb_str_buf_cat(str, "=", 1);
  rb_str_buf_append(str, attr_quote);
  rb_str_buf_append(str, value);
  rb_str_buf_append(str, attr_quote);
  return str;
}

static VALUE
build_attribute(VALUE attr_quote, int is_html, VALUE key, VALUE value)
{
  const char *key_cstr = StringValueCStr(key);
  if (strcmp(key_cstr, "class") == 0) {
    long len;

    Check_Type(value, T_ARRAY);
    len = RARRAY_LEN(value);
    if (len == 0) {
      return rb_str_new_cstr("");
    } else {
      long i;
      VALUE ary = rb_ary_new_capa(len);
      for (i = 0; i < len; i++) {
        VALUE v = RARRAY_AREF(value, i);
        rb_ary_push(ary, rb_funcall(v, id_to_s, 0));
      }
      rb_funcall(ary, id_sort_bang, 0);
      rb_funcall(ary, id_uniq_bang, 0);
      return put_attribute(attr_quote, key, rb_ary_join(ary, rb_str_new_cstr(" ")));
    }
  } else if (strcmp(key_cstr, "id") == 0) {
    long len = RARRAY_LEN(value);

    Check_Type(value, T_ARRAY);
    len = RARRAY_LEN(value);
    if (len == 0) {
      return rb_str_new_cstr("");
    } else {
      long i;
      VALUE ary = rb_ary_new_capa(len);
      for (i = 0; i < len; i++) {
        VALUE v = RARRAY_AREF(value, i);
        rb_ary_push(ary, rb_funcall(v, id_to_s, 0));
      }
      return put_attribute(attr_quote, key, rb_ary_join(ary, rb_str_new_cstr("_")));
    }
  } else {
    if (boolean_attribute_p(key_cstr)) {
      if (RB_TYPE_P(value, T_TRUE)) {
        if (is_html) {
          VALUE attr = rb_str_buf_new(1 + RSTRING_LEN(key));
          rb_str_buf_cat(attr, " ", 1);
          rb_str_buf_append(attr, key);
          return attr;
        } else {
          return put_attribute(attr_quote, key, key);
        }
      } else if (RB_TYPE_P(value, T_FALSE) || NIL_P(value)) {
        return Qnil;
      } else {
        return put_attribute(attr_quote, key, value);
      }
    } else {
      return put_attribute(attr_quote, key, value);
    }
  }
  return value;
}

static VALUE
m_build(int argc, VALUE *argv, RB_UNUSED_VAR(VALUE self))
{
  VALUE attr_quote, attributes, keys, buf;
  int is_html;
  long len, i;

  rb_check_arity(argc, 2, UNLIMITED_ARGUMENTS);
  attr_quote = argv[0];
  is_html = RTEST(argv[1]);
  attributes = rb_hash_new();
  rb_hash_aset(attributes, rb_str_new_cstr("id"), rb_ary_new());
  rb_hash_aset(attributes, rb_str_new_cstr("class"), rb_ary_new());
  merge(attributes, argc-2, argv+2);

  keys = rb_funcall(attributes, id_keys, 0);
  rb_funcall(keys, id_sort_bang, 0);
  len = RARRAY_LEN(keys);
  buf = rb_ary_new_capa(len);
  for (i = 0; i < len; i++) {
    VALUE k = RARRAY_AREF(keys, i);
    rb_ary_push(buf, build_attribute(attr_quote, is_html, k, rb_hash_lookup(attributes, k)));
  }

  return rb_ary_join(buf, Qnil);
}

static VALUE
m_normalize_data(RB_UNUSED_VAR(VALUE self), VALUE data)
{
  return normalize_data(data);
}

static VALUE
m_boolean_attribute_p(RB_UNUSED_VAR(VALUE self), VALUE key)
{
  const char *key_cstr = StringValueCStr(key);
  if (boolean_attribute_p(key_cstr)) {
    return Qtrue;
  } else {
    return Qfalse;
  }
}

void
Init_attribute_builder(void)
{
  VALUE mFaml = rb_define_module("Faml");
  rb_mAttributeBuilder = rb_define_module_under(mFaml, "AttributeBuilder");
  rb_define_singleton_method(rb_mAttributeBuilder, "build", RUBY_METHOD_FUNC(m_build), -1);
  rb_define_singleton_method(rb_mAttributeBuilder, "normalize_data", RUBY_METHOD_FUNC(m_normalize_data), 1);
  rb_define_singleton_method(rb_mAttributeBuilder, "boolean_attribute?", RUBY_METHOD_FUNC(m_boolean_attribute_p), 1);

  id_keys = rb_intern("keys");
  id_sort_bang = rb_intern("sort!");
  id_uniq_bang = rb_intern("uniq!");
  id_merge_bang = rb_intern("merge!");
  id_temple = rb_intern("Temple");
  id_utils = rb_intern("Utils");
  id_escape_html = rb_intern("escape_html");
  id_gsub = rb_intern("gsub");
  id_to_s = rb_intern("to_s");
  rb_require("temple");
}

#include <ruby.h>
#include <ruby/encoding.h>
#include <ruby/version.h>
#include "houdini.h"

#if (RUBY_API_VERSION_MAJOR > 2) || (RUBY_API_VERSION_MAJOR == 2 && RUBY_API_VERSION_MINOR >= 1)
/* define nothing */
#else
# define RARRAY_AREF(a, i) RARRAY_PTR(a)[i]
# define rb_ary_new_capa rb_ary_new2
#endif

VALUE rb_mAttributeBuilder;
static ID id_keys, id_sort_bang, id_uniq_bang, id_merge_bang;
static ID id_id, id_class, id_underscore, id_hyphen, id_space, id_equal;

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
  key = rb_convert_type(key, T_STRING, "String", "to_s");
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
  VALUE k = rb_convert_type(arg->key, T_STRING, "String", "to_s");

  k = substitute_underscores(k);
  if (OBJ_FROZEN(k)) {
    k = rb_str_dup(k);
  }
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
    key = rb_convert_type(key, T_STRING, "String", "to_s");
    key = substitute_underscores(key);
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

static int
put_data_attribute(VALUE key, VALUE val, VALUE hash)
{
  VALUE k = rb_str_buf_new(5 + RSTRING_LEN(key));
  rb_str_buf_cat(k, "data-", 5);
  rb_str_buf_append(k, key);
  rb_hash_aset(hash, k, val);
  return ST_CONTINUE;
}

static void
normalize(VALUE hash)
{
  VALUE keys = rb_funcall(hash, id_keys, 0);
  const long len = RARRAY_LEN(keys);
  long i;
  for (i = 0; i < len; i++) {
    VALUE key = RARRAY_AREF(keys, i);
    VALUE value = rb_hash_lookup(hash, key);
    VALUE key_str = rb_convert_type(key, T_STRING, "String", "to_s");

    if (RB_TYPE_P(value, T_HASH) && RSTRING_LEN(key_str) == 4 && memcmp(RSTRING_PTR(key_str), "data", 4) == 0) {
      VALUE data;

      rb_hash_delete(hash, key);
      data = normalize_data(value);
      rb_hash_foreach(data, put_data_attribute, hash);
    } else if (!(RB_TYPE_P(value, T_TRUE) || RB_TYPE_P(value, T_FALSE) || NIL_P(value))) {
      rb_hash_aset(hash, key_str, rb_convert_type(value, T_STRING, "String", "to_s"));
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
    concat_array_attribute(attributes, h, rb_const_get(rb_mAttributeBuilder, id_class));
    concat_array_attribute(attributes, h, rb_const_get(rb_mAttributeBuilder, id_id));
    normalize(h);
    rb_funcall(attributes, id_merge_bang, 1, h);
  }
}

static void
put_attribute(VALUE buf, VALUE attr_quote, VALUE key, VALUE value)
{
  gh_buf ob = GH_BUF_INIT;

  value = rb_convert_type(value, T_STRING, "String", "to_s");
  if (houdini_escape_html(&ob, (const uint8_t *)RSTRING_PTR(value), RSTRING_LEN(value))) {
    value = rb_enc_str_new(ob.ptr, ob.size, rb_utf8_encoding());
    gh_buf_free(&ob);
  }

  rb_ary_push(buf, rb_const_get(rb_mAttributeBuilder, id_space));
  rb_ary_push(buf, key);
  rb_ary_push(buf, rb_const_get(rb_mAttributeBuilder, id_equal));
  rb_ary_push(buf, attr_quote);
  rb_ary_push(buf, value);
  rb_ary_push(buf, attr_quote);
}

static void
build_attribute(VALUE buf, VALUE attr_quote, int is_html, VALUE key, VALUE value)
{
  Check_Type(key, T_STRING);
  if (RSTRING_LEN(key) == 5 && memcmp(RSTRING_PTR(key), "class", 5) == 0) {
    long len;

    Check_Type(value, T_ARRAY);
    len = RARRAY_LEN(value);
    if (len != 0) {
      long i;
      VALUE ary = rb_ary_new_capa(len);
      for (i = 0; i < len; i++) {
        VALUE v = RARRAY_AREF(value, i);
        rb_ary_push(ary, rb_convert_type(v, T_STRING, "String", "to_s"));
      }
      rb_funcall(ary, id_sort_bang, 0);
      rb_funcall(ary, id_uniq_bang, 0);
      put_attribute(buf, attr_quote, key, rb_ary_join(ary, rb_const_get(rb_mAttributeBuilder, id_space)));
    }
  } else if (RSTRING_LEN(key) == 2 && memcmp(RSTRING_PTR(key), "id", 2) == 0) {
    long len = RARRAY_LEN(value);

    Check_Type(value, T_ARRAY);
    len = RARRAY_LEN(value);
    if (len != 0) {
      long i;
      VALUE ary = rb_ary_new_capa(len);
      for (i = 0; i < len; i++) {
        VALUE v = RARRAY_AREF(value, i);
        rb_ary_push(ary, rb_convert_type(v, T_STRING, "String", "to_s"));
      }
      put_attribute(buf, attr_quote, key, rb_ary_join(ary, rb_const_get(rb_mAttributeBuilder, id_underscore)));
    }
  } else if (RB_TYPE_P(value, T_TRUE)) {
    if (is_html) {
      rb_ary_push(buf, rb_const_get(rb_mAttributeBuilder, id_space));
      rb_ary_push(buf, key);
    } else {
      put_attribute(buf, attr_quote, key, key);
    }
  } else if (RB_TYPE_P(value, T_FALSE) || NIL_P(value)) {
    /* do nothing */
  } else {
    put_attribute(buf, attr_quote, key, value);
  }
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
  rb_hash_aset(attributes, rb_const_get(rb_mAttributeBuilder, id_id), rb_ary_new());
  rb_hash_aset(attributes, rb_const_get(rb_mAttributeBuilder, id_class), rb_ary_new());
  merge(attributes, argc-2, argv+2);

  keys = rb_funcall(attributes, id_keys, 0);
  rb_funcall(keys, id_sort_bang, 0);
  len = RARRAY_LEN(keys);
  buf = rb_ary_new();
  for (i = 0; i < len; i++) {
    VALUE k = RARRAY_AREF(keys, i);
    build_attribute(buf, attr_quote, is_html, k, rb_hash_lookup(attributes, k));
  }

  return rb_ary_join(buf, Qnil);
}

static VALUE
m_normalize_data(RB_UNUSED_VAR(VALUE self), VALUE data)
{
  return normalize_data(data);
}

void
Init_attribute_builder(void)
{
  VALUE mFaml = rb_define_module("Faml");
  rb_mAttributeBuilder = rb_define_module_under(mFaml, "AttributeBuilder");
  rb_define_singleton_method(rb_mAttributeBuilder, "build", RUBY_METHOD_FUNC(m_build), -1);
  rb_define_singleton_method(rb_mAttributeBuilder, "normalize_data", RUBY_METHOD_FUNC(m_normalize_data), 1);

  id_keys = rb_intern("keys");
  id_sort_bang = rb_intern("sort!");
  id_uniq_bang = rb_intern("uniq!");
  id_merge_bang = rb_intern("merge!");

  id_id = rb_intern("ID");
  id_class = rb_intern("CLASS");
  id_underscore = rb_intern("UNDERSCORE");
  id_hyphen = rb_intern("HYPHEN");
  id_space = rb_intern("SPACE");
  id_equal = rb_intern("EQUAL");

  rb_const_set(rb_mAttributeBuilder, id_id, rb_obj_freeze(rb_str_new_cstr("id")));
  rb_const_set(rb_mAttributeBuilder, id_class, rb_obj_freeze(rb_str_new_cstr("class")));
  rb_const_set(rb_mAttributeBuilder, id_underscore, rb_obj_freeze(rb_str_new_cstr("_")));
  rb_const_set(rb_mAttributeBuilder, id_hyphen, rb_obj_freeze(rb_str_new_cstr("-")));
  rb_const_set(rb_mAttributeBuilder, id_space, rb_obj_freeze(rb_str_new_cstr(" ")));
  rb_const_set(rb_mAttributeBuilder, id_equal, rb_obj_freeze(rb_str_new_cstr("=")));
}

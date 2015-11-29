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

#define FOREACH_FUNC(func) ((int (*)(ANYARGS))(func))

VALUE rb_mAttributeBuilder;
static ID id_keys, id_sort_bang, id_uniq_bang, id_merge_bang, id_flatten;
static ID id_id, id_class, id_underscore, id_hyphen, id_space, id_equal;

static void
concat_array_attribute(VALUE attributes, VALUE key, VALUE value)
{
  VALUE ary;

  if (RB_TYPE_P(value, T_ARRAY)) {
    value = rb_funcall(value, id_flatten, 0);
  } else {
    value = rb_Array(value);
  }
  ary = rb_hash_lookup(attributes, key);
  Check_Type(ary, T_ARRAY);
  rb_ary_concat(ary, value);
}

static int
cstr_equal(VALUE rbstr, const char *cstr, long len)
{
  return RSTRING_LEN(rbstr) == len && memcmp(RSTRING_PTR(rbstr), cstr, len) == 0;
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
    rb_hash_foreach(normalize_data(value), FOREACH_FUNC(normalize_data_i2), (VALUE)(&arg));
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
put_data_attribute(VALUE key, VALUE val, VALUE hash)
{
  VALUE k = rb_str_buf_new(5 + RSTRING_LEN(key));
  rb_str_buf_cat(k, "data-", 5);
  rb_str_buf_append(k, key);
  rb_hash_aset(hash, k, val);
  return ST_CONTINUE;
}

static int
merge_one_i(VALUE key, VALUE value, VALUE attributes)
{
  key = rb_convert_type(key, T_STRING, "String", "to_s");
  if (cstr_equal(key, "class", 5)) {
    concat_array_attribute(attributes, key, value);
  } else if (cstr_equal(key, "id", 2)) {
    concat_array_attribute(attributes, key, value);
  } else if (cstr_equal(key, "data", 4) && RB_TYPE_P(value, T_HASH)) {
    VALUE data = normalize_data(value);
    rb_hash_foreach(data, FOREACH_FUNC(put_data_attribute), attributes);
  } else if (RB_TYPE_P(value, T_TRUE) || !RTEST(value)) {
    /* Keep Qtrue, Qfalse and Qnil */
    rb_hash_aset(attributes, key, value);
  } else {
    rb_hash_aset(attributes, key, rb_convert_type(value, T_STRING, "String", "to_s"));
  }
  return ST_CONTINUE;
}

static void
merge_one(VALUE attributes, VALUE h)
{
  Check_Type(h, T_HASH);
  rb_hash_foreach(h, FOREACH_FUNC(merge_one_i), attributes);
}

static void
join_class_attribute(VALUE attributes, VALUE key)
{
  long len;
  VALUE val;

  val = rb_hash_delete(attributes, key);
  Check_Type(val, T_ARRAY);
  len = RARRAY_LEN(val);
  if (len != 0) {
    long i;
    VALUE ary = rb_ary_new_capa(len);
    for (i = 0; i < len; i++) {
      VALUE v = RARRAY_AREF(val, i);
      if (RTEST(v)) {
        rb_ary_concat(ary, rb_str_split(rb_convert_type(v, T_STRING, "String", "to_s"), " "));
      }
    }
    rb_funcall(ary, id_sort_bang, 0);
    rb_funcall(ary, id_uniq_bang, 0);
    rb_hash_aset(attributes, key, rb_ary_join(ary, rb_const_get(rb_mAttributeBuilder, id_space)));
  }
}

static void
join_id_attribute(VALUE attributes, VALUE key)
{
  long len;
  VALUE val;

  val = rb_hash_delete(attributes, key);
  Check_Type(val, T_ARRAY);
  len = RARRAY_LEN(val);
  if (len != 0) {
    long i;
    VALUE ary = rb_ary_new_capa(len);
    for (i = 0; i < len; i++) {
      VALUE v = RARRAY_AREF(val, i);
      if (RTEST(v)) {
        rb_ary_push(ary, rb_convert_type(v, T_STRING, "String", "to_s"));
      }
    }
    rb_hash_aset(attributes, key, rb_ary_join(ary, rb_const_get(rb_mAttributeBuilder, id_underscore)));
  }
}

static int
delete_falsey_values_i(RB_UNUSED_VAR(VALUE key), VALUE value, RB_UNUSED_VAR(VALUE arg))
{
  if (RTEST(value)) {
    return ST_CONTINUE;
  } else {
    return ST_DELETE;
  }
}

static void
delete_falsey_values(VALUE attributes)
{
  rb_hash_foreach(attributes, FOREACH_FUNC(delete_falsey_values_i), Qnil);
}

static VALUE
merge(VALUE object_ref, int argc, VALUE *argv)
{
  VALUE attributes, id_str, class_str;
  int i;

  attributes = rb_hash_new();
  id_str = rb_const_get(rb_mAttributeBuilder, id_id);
  class_str = rb_const_get(rb_mAttributeBuilder, id_class);
  rb_hash_aset(attributes, id_str, rb_ary_new());
  rb_hash_aset(attributes, class_str, rb_ary_new());

  for (i = 0; i < argc; i++) {
    merge_one(attributes, argv[i]);
  }
  if (!NIL_P(object_ref)) {
    merge_one(attributes, object_ref);
  }

  join_class_attribute(attributes, class_str);
  join_id_attribute(attributes, id_str);
  delete_falsey_values(attributes);

  return attributes;
}

static void
put_attribute(VALUE buf, VALUE attr_quote, VALUE key, VALUE value)
{
  gh_buf ob = GH_BUF_INIT;

  Check_Type(value, T_STRING);
  if (houdini_escape_html0(&ob, (const uint8_t *)RSTRING_PTR(value), RSTRING_LEN(value), 0)) {
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
  if (RB_TYPE_P(value, T_TRUE)) {
    if (is_html) {
      rb_ary_push(buf, rb_const_get(rb_mAttributeBuilder, id_space));
      rb_ary_push(buf, key);
    } else {
      put_attribute(buf, attr_quote, key, key);
    }
  } else {
    put_attribute(buf, attr_quote, key, value);
  }
}

static VALUE
m_build(int argc, VALUE *argv, RB_UNUSED_VAR(VALUE self))
{
  VALUE attr_quote, object_ref, attributes, keys, buf;
  int is_html;
  long len, i;

  rb_check_arity(argc, 3, UNLIMITED_ARGUMENTS);
  attr_quote = argv[0];
  is_html = RTEST(argv[1]);
  object_ref = argv[2];
  attributes = merge(object_ref, argc-3, argv+3);

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

static VALUE
m_merge(int argc, VALUE *argv, RB_UNUSED_VAR(VALUE self))
{
  rb_check_arity(argc, 1, UNLIMITED_ARGUMENTS);
  return merge(argv[0], argc-1, argv+1);
}

void
Init_attribute_builder(void)
{
  VALUE mFaml = rb_define_module("Faml");
  rb_mAttributeBuilder = rb_define_module_under(mFaml, "AttributeBuilder");
  rb_define_singleton_method(rb_mAttributeBuilder, "build", RUBY_METHOD_FUNC(m_build), -1);
  rb_define_singleton_method(rb_mAttributeBuilder, "normalize_data", RUBY_METHOD_FUNC(m_normalize_data), 1);
  rb_define_singleton_method(rb_mAttributeBuilder, "merge", RUBY_METHOD_FUNC(m_merge), -1);

  id_keys = rb_intern("keys");
  id_sort_bang = rb_intern("sort!");
  id_uniq_bang = rb_intern("uniq!");
  id_merge_bang = rb_intern("merge!");
  id_flatten = rb_intern("flatten");

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

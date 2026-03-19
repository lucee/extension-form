# Changelog

## 2.0.0.7

- [LDEV-6158](https://luceeserver.atlassian.net/browse/LDEV-6158) — fix jakarta/javax bytecode binding in `javax/Form.java`, use `eng.getClassUtil().callMethod()` reflection to avoid compile-time servlet API binding
- CI: build once, test against Lucee 6.2 + 7.0, gate deploy to master

## 2.0.0.6

- [LDEV-6073](https://luceeserver.atlassian.net/browse/LDEV-6073) — add missing files in single mode
- Add javax/jakarta dual TLD support ([LDEV-6120](https://luceeserver.atlassian.net/browse/LDEV-6120))
- Switch to maven build, Jakarta EE migration for Lucee 7

## Earlier

- [LDEV-2370](https://luceeserver.atlassian.net/browse/LDEV-2370) — form tag fix
- [LDEV-1613](https://luceeserver.atlassian.net/browse/LDEV-1613) — form tag fix
- Add expires header for `formtag-form`

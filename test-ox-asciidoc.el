;;; ox-asciidoc.el --- Test code for ox-asciidoc.el

;; Copyright (C) 2013 Yasushi SHOJI

;; Author: Yasushi SHOJI <yasushi.shoji@gmail.com>
;; Keywords: org, asciidoc

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This is test code for ox-asciidoc.el.
;;
;; You can load this file with `load-file' and run the test with
;; `ert', Emacs Lisp Regression Testing.
;;
;; The test code depends on org-mode/testing/org-test.el.  So, make
;; sure you have org-test.el loaded or have it in your load path.
;; (add-to-list 'load-path "org-mode/testing")
;;
;; Obviously, you should have had ox-asciidoc.el in your load path,
;; too.

;;; Code:
(require 'org-test)
(require 'ox-asciidoc)

(defun org-asciidoc-test-transcode-with-template (str1 str2)
  (should (equal (org-test-with-temp-text str1
		   (org-export-as 'asciidoc))
		 str2)))

(ert-deftest test-rog-asciidoc/title ()
  (org-asciidoc-test-transcode-with-template
   "#+AUTHOR: John Smith
#+Title: This is the title"

   "= This is the title =
John Smith

")

  (org-asciidoc-test-transcode-with-template
   "#+Title: This is the title
#+AUTHOR: John Smith
#+Date: 2001-01-01"

   "= This is the title =
John Smith
2001-01-01

")
  )

(defun org-asciidoc-test-transcode-body (str1 str2)
  (should (equal (org-test-with-temp-text str1
		   (org-export-as 'asciidoc nil nil t))
		 str2)))


;;; Inline Text Format
(ert-deftest test-org-asciidoc/bold-to-strong ()
  (org-asciidoc-test-transcode-body
   "*foo*"
   "*foo*\n")
  (org-asciidoc-test-transcode-body
   "*foo ~ bar*"
   "*foo \\~ bar*\n"))

(ert-deftest test-org-asciidoc/italic-to-emphasized ()
  (org-asciidoc-test-transcode-body
   "/foo/"
   "'foo'\n")
  (org-asciidoc-test-transcode-body
   "/foo ~ bar/"
   "'foo \\~ bar'\n"))

(ert-deftest test-org-asciidoc/underlined-to-underline ()
  (org-asciidoc-test-transcode-body
   "_foo_"
   "[underline]#foo#\n")
    (org-asciidoc-test-transcode-body
   "_foo ~ bar_"
   "[underline]#foo \\~ bar#\n"))

(ert-deftest test-org-asciidoc/code-to-monospaced ()
  (org-asciidoc-test-transcode-body
   "=foo="
   "`foo`\n")
  (org-asciidoc-test-transcode-body
   "=foo ~ bar="
   "`foo \\~ bar`\n"))

(ert-deftest test-org-asciidoc/verbatim-to-monospaced ()
  (org-asciidoc-test-transcode-body
   "~foo~"
   "`foo`\n")
  (org-asciidoc-test-transcode-body
   "~foo ~ bar~"
   "`foo \\~ bar`\n"))

(ert-deftest test-org-asciidoc/strikethrough-to-linethrough ()
  (org-asciidoc-test-transcode-body
   "+foo+"
   "[line-through]#foo#\n")
  (org-asciidoc-test-transcode-body
   "+foo ~ bar+"
   "[line-through]#foo \\~ bar#\n"))


;;; Headlines to Titles
(ert-deftest test-org-asciidoc/headline ()
  (org-asciidoc-test-transcode-body
   "* 1st headline
** 2nd headline
*** 3rd headline
**** 4th headline
***** 5th headline
****** 6th headline
******* 7th headline"
"\n== 1st headline ==

=== 2nd headline ===

==== 3rd headline ====

===== 4th headline =====
* 5th headline
** 6th headline
*** 7th headline
"))

(ert-deftest test-org-asciidoc/headline ()
  (org-asciidoc-test-transcode-body
   "* 1st headline
* 2nd headline
* Footnotes
* 3rd headline"

   "
== 1st headline ==

== 2nd headline ==

== 3rd headline ==
"))

;;; List
(ert-deftest test-org-asciidoc/unordered-list ()
  (org-asciidoc-test-transcode-body
   "- list\n"
   "* list\n")
  (org-asciidoc-test-transcode-body
   "- list\n- list"
   "* list\n* list\n")
  (org-asciidoc-test-transcode-body
   "- list\n  - list"
   "* list\n** list\n")
  (org-asciidoc-test-transcode-body
   "
- list
  - list
    - list
      - list
        - list"
   "* list
** list
*** list
**** list
***** list\n"))

(ert-deftest test-org-asciidoc/ordered-list ()
  (org-asciidoc-test-transcode-body
   "1. list 1
2. list 2
3. list 3"
   ". list 1
. list 2
. list 3\n")
  (org-asciidoc-test-transcode-body
   "1. list 1\n
2. list 2\n
3. list 3\n"
   ". list 1\n
. list 2\n
. list 3\n")
    (org-asciidoc-test-transcode-body
   "1. list 1

2. list 2

3. list 3"

   ". list 1

. list 2

. list 3\n")
    (org-asciidoc-test-transcode-body
   "1. list 1

2. list 2
3. list 3"

   ". list 1

. list 2
. list 3\n")
    (org-asciidoc-test-transcode-body
   "1. list 1


2. list 2
3. list 3"

   ". list 1


// ^

. list 2
. list 3\n")
  )

(ert-deftest test-org-asciidoc/ordered-list-continuation ()
  (org-asciidoc-test-transcode-body
   "
1. foo

   this is foo

2. bar

   this is bar

3. baz

   this is baz
"
   ". foo
+
this is foo

. bar
+
this is bar

. baz
+
this is baz
"))

(ert-deftest test-org-asciidoc/unordered-list-following-para ()
  (org-asciidoc-test-transcode-body
   "this is a paragraph.
- and org allows any list to start right after para"

   "this is a paragraph.

* and org allows any list to start right after para\n")

    (org-asciidoc-test-transcode-body
   "* this is a headline
- and org allows any list to start right after it"

   "\n== this is a headline ==
* and org allows any list to start right after it\n")

    (org-asciidoc-test-transcode-body
   "* this is a headline
- and this is a list
  - and org allows any list to start right after it"

   "\n== this is a headline ==
* and this is a list
** and org allows any list to start right after it\n")
    )


;;; Footnote
(ert-deftest test-org-asciidoc/footnote ()
  (org-asciidoc-test-transcode-body
   "This is body [fn:1: This is inline footnote]."

   "This is body footnoteref:[1, This is inline footnote].
"))


;;; Example Blocks to Listing Blocks
(ert-deftest test-org-asciidoc/example-block-to-listing-block ()
  (org-asciidoc-test-transcode-body
   "#+BEGIN_EXAMPLE
int main(void) {
    printf(\"Hello, World\");
}
#+END_EXAMPLE"

   "....
int main(void) {
    printf(\"Hello, World\");
}
....
"))


;;; Fixed width
(ert-deftest test-org-asciidoc/fixed-width ()
  (org-asciidoc-test-transcode-body
   ": this is fixed width"
   "....
this is fixed width
....
")
  (org-asciidoc-test-transcode-body
   ": how about
: multi-lines"
   "....
how about
multi-lines
....
"))

;;; Plain Text
(ert-deftest test-org-asciidoc/plain-text ()
  (org-asciidoc-test-transcode-body
   "~" "\\~\n")
  (org-asciidoc-test-transcode-body
   "~asdf"
   "\\~asdf\n")
  (org-asciidoc-test-transcode-body
   "asdf~"
   "asdf\\~\n")
  (org-asciidoc-test-transcode-body
   "asdf~asdf"
   "asdf\\~asdf\n")
  (org-asciidoc-test-transcode-body
   "asdf ~ asdf"
   "asdf \\~ asdf\n")
  (org-asciidoc-test-transcode-body
   "asdf *~* asdf"
   "asdf *\\~* asdf\n")
  (org-asciidoc-test-transcode-body
   "asdf ~ asdf ~ asdf"
   "asdf \\~ asdf \\~ asdf\n")
  (org-asciidoc-test-transcode-body
   "asdf ~asdf ~asdf"
   "asdf \\~asdf \\~asdf\n")
  (org-asciidoc-test-transcode-body
   "*asdf ~asdf asdf*"
   "*asdf \\~asdf asdf*\n")
  (org-asciidoc-test-transcode-body
   "~asdf ~asdf asdf~"
   "`asdf \\~asdf asdf`\n")
  (org-asciidoc-test-transcode-body
   "=asdf ~asdf asdf="
   "`asdf \\~asdf asdf`\n"))


;;; Tables
(ert-deftest test-org-asciidoc/table-to-table ()
  (org-asciidoc-test-transcode-body
   "| Name  | Phone | Age |
|-------+-------+-----|
| Peter |  1234 |  17 |
| Anna  |  4321 |  25 |
"
   "[width=\"80%\",options=\"header\"]
|====
| Name| Phone| Age

| Peter| 1234| 17
| Anna| 4321| 25
|====
")
  (org-asciidoc-test-transcode-body
   "#+ATTR_ASCIIDOC: :pgwide t
| Name  | Phone | Age |
|-------+-------+-----|
| Peter |  1234 |  17 |
| Anna  |  4321 |  25 |
"
   "[width=\"80%\",options=\"header,pgwide\"]
|====
| Name| Phone| Age

| Peter| 1234| 17
| Anna| 4321| 25
|====
"))


;;; Source block
(ert-deftest test-org-asciidoc/source ()
  (org-asciidoc-test-transcode-body
   "#+BEGIN_SRC emacs-lisp
  (defun org-xor (a b)
    \"Exclusive or.\"
    (if a (not b) b))
#+END_SRC"

   "[source,emacs-lisp]
----
(defun org-xor (a b)
  \"Exclusive or.\"
  (if a (not b) b))
----
"))

(ert-deftest test-org-asciidoc/source-with-linenumber ()
  (org-asciidoc-test-transcode-body
   "#+BEGIN_SRC C -n
#include <stdio.h>
int main(int argc, char *argv[])
{
	printf(\"Hello, World\");
	return 0;
}
#+END_SRC"

   "[source,C,linenums]
----
#include <stdio.h>
int main(int argc, char *argv[])
{
	printf(\"Hello, World\");
	return 0;
}
----
"))

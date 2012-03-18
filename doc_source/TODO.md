Allgemein
=========

* rails_xss / erubis
* E-Mail-Addressen-Filter für Texte
* write help for Markdown **pending**


Bugs
====


Refactoring
===========

* convert `.erb` → `.haml` **pending**
* Change ['thing', 'or', ...] → %w(thing or ...) **pending**
* There is no extra mobile view for fair dates
* Anpassen von filter_parameter_logging
* Routes


Daueraufgaben
=============

* Tests
* Unterstützte Browser

Verlauf
=======

18\. März 2012
--------------
* write help for Markdown **pending** (3 Stunden)
* render `user#notes`, … with Markdown; overwrite default accessor **done**
* add validation for Markdown input **done**
  * add for `FairDate#comment` **done**
  * add for `User#notes` **done**
  * add for `Article#description` **done**
* Change ['thing', 'or', ...] → %w(thing or ...) **pending**

17\. März 2012
--------------
* Guard TODO.md **done**
* convert `.erb` → `.haml` **pending** (1 Stunde)

16\. März 2012
-------------
* Haml **done**
* Markdown **done**
* class FlashMessage **done**
* flash[:message] gibt einen Hash als :text an render_to_string weiter und nimmt das Ergebnis als Text **done**
* refactor update_password **done**
* session params über flash weitergeben **done**

;;; LITERATE-DEVOPS-DEMO --- Summary
;;
;; Author: Howard Abrams <howard.abrams@gmail.com>
;; Copyright © 2015, Howard Abrams, all rights reserved.
;; Created:  8 August 2015
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;;
;;  Demonstration code using the 'demo-it' package to show off how to
;;  build up a literate programming org-mode file showing off system
;;  administration.
;;
;;
;;; Change log:
;;
;;  v1. The results of the EmacsConf 2015 presentation
;;
;;  v2. Code modification to the YouTube recording
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Code:

(require 'demo-it)
(require 'org-tree-slide)

(setq org-babel-sh-command "bash --login")

;; ----------------------------------------------------------------------
;;  Helper Functions
;;
;;  I would like a function that inserts a phrase or paragraph into a
;;  buffer, but that it is looks like it is being typed. This means to
;;  have a slight, but random time delay between each letter. Calling
;;  `sit-for' is sufficient for short sentences (around 140
;;  characters), but anything longer makes the display look like it
;;  hangs until some event, and then the entire results are displayed.
;;
;;  Ideas or thoughts on what to look for?

(defun insert-typewriter (str)
  "Insert STR into the current buffer as if you were typing it by hand."
  (interactive "s")
  ;; (insert str)
  (dolist (ch (string-to-list str))
    (insert ch)
    (sit-for (/ 1.0 (+ 10 (random 100))) nil)))

(defun jump-forward (phrase)
  "Move forward looking for PHRASE.  If not found, jump backward to it."
  (if (not (search-forward phrase nil t))
      (search-backward phrase nil t)))

(defun jump-backward (phrase)
  "Move backward looking for PHRASE.  If not found, jump foreward to it."
  (if (not (search-backward phrase nil t))
      (search-forward phrase nil t)))

(defun devops-append-space (&optional back-string)
  "Add blank line to end of buffer.
If given BACK-STRING, jumps back to that text string, otherwise,
just moves one line back."
  (interactive)
  (goto-char (point-max))
  (open-line 2)
  (if back-string
      (search-backward back-string)
    (forward-line -1)))

;; ----------------------------------------------------------------------
;;  Create each function that represents a "presentation frame"

(defun devops-display-notes ()
  "Show the presentation note in another frame."
  (interactive)
  (find-file-other-frame "presentation-notes.org")
  (text-scale-set 2)
  (org-global-cycle 0)
  (modify-frame-parameters nil '((line-spacing . 8)))
  (goto-char (point-min))
  (search-forward-regexp "^ *$")
  (recenter 0)
  (switch-to-buffer "title-screen.org"))

(defun devops-title-screen ()
  "Show off the title screen."
  (interactive)

  (set-frame-size nil 160 40)   ;; Fit for 1280 x 720
  (demo-it-title-screen "title-screen.org" 6)
  (highlight-regexp "Literate Devops" "hi-green-b")
  ;; (devops-display-notes)
  )

(defun devops-load-presentation ()
  "Display literate-devops-demo.org (an 'org-mode' file) as a presentation."
  (interactive)
  (org-tree-slide-simple-profile)
  (demo-it-presentation "presentation.org" 5))

(defun devops-presentation-compare-files ()
  "Display the literate programming differences side-by-side."
  (interactive)
  (demo-it-show-image "example-code-norm.png" 'below)
  (enlarge-window 1)
  (demo-it-show-image "example-code-lit.png" 'side)
  (message "Ruby initialization started."))

(defun devops-presentation-compare-files-close ()
  "Close the literate programming windows."
  (interactive)
  ;; Because of the delay in display the Ruby code, I'm just going to
  ;; do a screen shot of the source code and turn it into an image...
  ;; (switch-to-buffer "example-code-norm.rb")
  (switch-to-buffer "example-code-norm.png")
  (kill-buffer-and-window)
  ;; (switch-to-buffer "example-code-lit.md")
  (switch-to-buffer "example-code-lit.png")
  (kill-buffer-and-window))

(defun devops-load-source-code ()
  "Load some source code in a side window."
  (interactive)
  (demo-it-load-file "sprint-fuzzy-bunny.org" nil 4)
  (widen)
  (delete-region (point-min) (point-max))
  (org-mode)
  (yas-minor-mode-on)
  (text-scale-set 3))

(defun devops-sprint-snippet1 ()
  "Start the sprint 'org-mode' file with my 'sprint' yasnippet."
  (interactive)
  (insert-typewriter "sprint"))

(defun devops-sprint-snippet2 ()
  "Expand the 'sprint' yasnippet."
  (interactive)
  (condition-case nil
      (call-interactively
       (yas-expand-snippet "#+TITLE:  Sprint: $1
#+AUTHOR: `(user-full-name)`
#+EMAIL:  `user-mail-address`
#+DATE:   `(format-time-string \"%Y-%m-%d\")`

Notes and resolution of work issues during the '$1' sprint.

* Work Issues

  $0

* Meeting Notes

* Daily Scrum Status

* Sprint Demonstration

* Notes for Next Sprint" (point-min) (point-max)))))

(defun devops-sprint-snippet3 ()
  "Pretend like we are running a Jira suckage program."
  (interactive)
  (save-excursion
    (goto-char (point-max))
    (insert "

#+PROPERTY:    results output replace
#+PROPERTY:    tangle no
#+PROPERTY:    eval no-export
#+PROPERTY:    comments org
#+OPTIONS:     num:nil toc:nil todo:nil tasks:nil tags:nil skip:nil author:nil email:nil creator:nil timestamp:nil")
    (forward-line -2)
    (org-ctrl-c-ctrl-c)
    (search-backward "Notes for Next Sprint")
    (org-cycle))

  (jump-backward "Work Issues")
  (forward-line 2)
  (insert "** Extend Project Scope with Lint Checking | [[blah1][WC-152]]

** Create a Setup File for Better Installation | [[blah1][WC-134]]

*** Verify the Installable Archive

** Set up a Chef Server for Deployment | [[blah1][WC-181]]

*** Install Chef Binaries
*** Upload Cookbooks
*** Connect the Clients

** Deploy the Project Application | [[blah1][WC-182]]

*** Install Python Server

*** Install Apache with WSGI

** Create Local Dev Environment with Docker | [[blah1][WC-195]]")
  (sit-for 2)
  (goto-char (point-min))

  (search-forward "Better Installation")
  (org-cycle)
  (search-forward "Chef Server for Deployment")
  (org-cycle)
  (search-forward "Deploy the Project")
  (org-cycle))

(defun devops-section1-1 ()
  "Start typing."
  (interactive)
  (goto-char (point-min))
  (search-forward "Extend Project Scope with Lint Checking")
  (end-of-line)
  (insert-typewriter "

   After researching many alternatives, including:
   - [[")
  (sit-for 2)
  (insert "http://www.pylint.org")
  (sit-for 1)
  (insert-typewriter "][Pylint]] :: Individual's can customize errors and conventions.
   - [[")
  (sit-for 2)
  (insert "http://pychecker.sourceforge.net")
  (sit-for 1)
  (insert-typewriter "][PyChecker]] :: hasn't been updated in years. Issue?
   - [[")
  (sit-for 2)
  (insert "https://pypi.python.org/pypi/pep8")
  (sit-for 1)
  (insert-typewriter "][Pep8]] :: Guido's original style guide.
   - [[")
  (sit-for 1.5)
  (insert "https://flake8.readthedocs.org/en/2.3.0/")
  (sit-for 0.5)
  (insert-typewriter "][Flake8]] :: Integrate both =pep8= /and/ =pyflakes=.

   ")
  (sit-for 2.5)
  (insert-typewriter "Since it wraps pep8 as well as [[")
  (sit-for 1.5)
  (insert "https://pypi.python.org/pypi/pyflakes")
  (sit-for 1)
  (insert-typewriter "][pyflakes]] error checking library,
   I’m sure that *Flake8* library should be sufficient for us.
   Thoughts?"))


(defun devops-section1-2 ()
  "Insert a code block."
  (interactive)
  (jump-backward "Thoughts")
  (sit-for 2)
  (kill-line)
  (open-line 1)
  (insert-typewriter "Install it in a virtual environment with:

   <s"))

(defun devops-section1-3 ()
  "Insert 'sh' for the code block."
  (interactive)
  (org-cycle)
  (sit-for 4)
  (end-of-line)
  (insert-typewriter "sh"))

(defun devops-section1-4 ()
  "Insert the contents of the code block."
  (interactive)
  (forward-line)
  (insert-typewriter "pyenv virtualenv demo
pyenv activate demo
pip install --upgrade flake8"))

(defun devops-section1-4results ()
  "Insert the error that should show up."
  (interactive)
  (jump-forward "END_SRC")
  (forward-line)
  (insert "
   #+RESULTS:
   #+begin_example
   Collecting virtualenv
     Using cached virtualenv-13.1.0-py2.py3-none-any.whl
   Installing collected packages: virtualenv
   Successfully installed virtualenv-13.1.0
   Collecting flake8
     Using cached flake8-2.4.1-py2.py3-none-any.whl
   Collecting pyflakes<0.9,>=0.8.1 (from flake8)
     Using cached pyflakes-0.8.1-py2.py3-none-any.whl
   Collecting pep8!=1.6.0,!=1.6.1,!=1.6.2,>=1.5.7 (from flake8)
     Using cached pep8-1.5.7-py2.py3-none-any.whl
   Collecting mccabe<0.4,>=0.2.1 (from flake8)
     Using cached mccabe-0.3.1-py2.py3-none-any.whl
   Installing collected packages: pyflakes, pep8, mccabe, flake8
   Successfully installed flake8-2.4.1 mccabe-0.3.1 pep8-1.5.7 pyflakes-0.8.1
   #+end_example")
  (jump-backward "begin_example")
  (demo-it-message-keybinding "C-c C-c" "org-ctrl-c-ctrl-c"))

(defun devops-section1-4update ()
  "Put the word exports code as a header."
  (interactive)
  (search-backward "#+BEGIN_SRC")
  (end-of-line)
  (insert-typewriter " :exports code"))


(defun devops-section1-highlight ()
  "Select the text we just typed."
  (interactive)
  (outline-previous-visible-heading 1)
  (forward-line 2)
  (set-mark (point))
  (jump-forward "END_SRC")
  (forward-line 1)
  (demo-it-message-keybinding "C-=" "er/expand-region"))

(defun devops-send-email ()
  (interactive)
  (demo-it-make-side-window)
  (org-mime-org-buffer-htmlize)
  (goto-char (point-min)))

(defun devops-section1-back-to-presentation ()
  "Swtich to presentation to show the next slide."
  (interactive)
  (message-kill-buffer)
  (switch-to-buffer "presentation.org")
  (demo-it-presentation-advance))

(defun devops-section1-5paragraph ()
  "Step in Section 1."
  (interactive)
  (switch-to-buffer "sprint-fuzzy-bunny.org")
  (deactivate-mark)

  (search-forward "#+end_example")
  (forward-line)
  (insert-typewriter "
   When I run the =flake8= executable on our current Reporter
   project, I get the following warnings:

   <s")
  (org-cycle)
  (insert-typewriter "sh
     flake8 --exit-zero reporter.py")
  (delete-char 1))

(defun devops-section1-5insert-cd ()
  "Step in Section 1."
  (interactive)
  (beginning-of-line)
  (open-line 1)
  (insert-typewriter "     cd $HOME/work/backend-stuff/wc-reporter/Reporter"))

(defun devops-section1-5dir-header ()
  "Step in Section 1."
  (interactive)
  (beginning-of-line)
  (kill-line 1)
  (forward-line -1)
  (end-of-line)
  (insert-typewriter " :dir Reporter"))

(defun devops-section1-6exports ()
  "Step in Section 1."
  (interactive)
  (insert-typewriter " :exports both"))

(defun devops-section2-paragraph ()
  "Step in Section 2."
  (interactive)
  (search-forward "Create a Setup File")
  (org-cycle)
  (forward-line)
  (insert-typewriter "
   To package the Reporter module as a package, we need to create a
   =setup.py= that imports the =setup= function:

   <s")
  (open-line 1)
  (sit-for 2)
  (org-cycle)
  (insert-typewriter "python"))

(defun devops-section2-sourcecode ()
  "Step in Section 2."
  (interactive)
  (forward-line)
  (insert-typewriter "  from setuptools import setup

     setup(name='Reporter',
           version='1.0',
           description='Helper instance for dealing with Nagios',
           author='Howard Abrams',
           author_email='howard.abrams@gmail.com',
           py_modules=['reporter'])"))

(defun devops-section2-tangleheader ()
  "Step in Section 2."
  (interactive)
  (search-backward "python")
  (end-of-line)
  (insert-typewriter " :tangle Reporter/setup.py"))

(defun devops-section3-start ()
  "Begin by jumping to the next section and un-hiding it."
  (interactive)
  (search-forward "Verify the Installable Archive")
  (beginning-of-line)
  (org-cycle 2) ;; since this is a sub-sub heading
  (end-of-line)
  (insert-typewriter "

    "))

(defun devops-section3-hide ()
  "Step in Section 3."
  (interactive)
  (org-narrow-to-subtree)
  (demo-it-message-keybinding "C-x n s" "org-narrow-to-subtree"))

(defun devops-section3-paragrah ()
  "Step in Section 3."
  (interactive)
  (insert-typewriter "With the source code for the =Reporter= project, we build the
    [[")
  (sit-for 2)
  (insert "https://docs.python.org/2/distutils/sourcedist.html")
  (sit-for 1)
  (insert-typewriter "][archive distribution archive]]:

    <s")
  (sit-for 1)
  (org-cycle)
  (insert-typewriter "sh :dir Reporter")
  (forward-line)
  (insert-typewriter "    python setup.py sdist")
  (devops-append-space))

(defun devops-section3-hideresults ()
  "Step in Section 3."
  (interactive)
  (jump-forward "#+begin_example")
  (org-cycle)
  (demo-it-message-keybinding "TAB" "org-cycle"))

(defun devops-section3-hi-dir ()
  (interactive)
  (highlight-regexp ":dir Reporter"))

(defun devops-section3-removereporter ()
  "Step in Section 3."
  (interactive)
  (unhighlight-regexp ":dir Reporter")
  (replace-string " :dir Reporter" "" nil (point-min) (point-max))
  (sit-for 2)
  (org-set-property "dir" "Reporter")
  (sit-for 3)
  (let ((current (point)))
    (search-backward ":PROPERTIES:")
    (org-cycle)
    (sit-for 3)
    (goto-char current))
  (demo-it-message-keybinding "C-c C-x p" "org-set-property"))

(defun devops-section3-nextparagraph ()
  "Step in Section 3."
  (interactive)
  (goto-char (point-max))
  (forward-line -1)
  (insert-typewriter "    Odd that the name of the archive isn’t actually displayed in
    the output of the =sdist= command.  The archive is the file in
    =dist= directory that matches the version we specified in the
    =setup.py= file.

    <s")
  (sit-for 1)
  (org-cycle)
  (insert "sh")
  (forward-line)
  (insert-typewriter "     ls dist")
  (devops-append-space))

(defun devops-section3-nameblock ()
  "Step in Section 3."
  (interactive)
  (search-forward "#+RESULTS")
  (beginning-of-line)
  (delete-region (point) (point-max))
  (search-backward "#+BEGIN_SRC")
  (forward-line -1)
  (insert-typewriter "
    #+NAME: tar-archive")
  (forward-line 2))

(defun devops-section3-tarparagraph ()
  "Step in Section 3."
  (interactive)
  (goto-char (point-max))
  (insert-typewriter "    The archive contains the following files:

    <s")
  (sit-for 1)
  (org-cycle)
  (insert-typewriter "sh :var ZIP=tar-archive")
  (forward-line)
  (insert-typewriter "      tar -tzf dist/$ZIP")
  (highlight-regexp "tar-archive")
  (devops-append-space))

(defun devops-section3-redisplaytar ()
  "Step in Section 3."
  (interactive)
  (jump-forward "#+RESULTS")
  (beginning-of-line)
  (delete-region (point) (point-max))
  (search-backward "#+BEGIN_SRC")
  (previous-line)
  (insert-typewriter "
    #+NAME: contents")
  (forward-line 1)
  (end-of-line)
  (insert-typewriter " :results table")
  (unhighlight-regexp "tar-archive")
  (highlight-regexp ":results table" "hi-green")
  (highlight-regexp "\\#\\+NAME: contents" "hi-blue")
  (devops-append-space "tar "))

(defun devops-section3-tarcontentsdetails ()
  "Step in Section 3."
  (interactive)
  (end-of-buffer)
  (unhighlight-regexp ":results table")
  (unhighlight-regexp "\\#\\+NAME: contents")
  (forward-line -2)
  (insert-typewriter "    The contents of the generated, =PKG-INFO=, show that we are
    missing some fields in our =setup.py= that we will want to describe:

    <s")
  (sit-for 1)
  (org-cycle)
  (insert-typewriter "sh :var ZIP=tar-archive CFG=contents[1,0]")

  (highlight-regexp "[^|]*0/PKG-INFO[^|]*" "hi-pink")
  (highlight-regexp "contents\\[1,0\\]" "hi-pink")

  (forward-line)
  ;; The following works well on Linux, but not on the Mac that I will be using to display things.
  ;; (insert-typewriter "  tar -xzf dist/$ZIP --to-command=cat $CFG")
  (insert-typewriter "    tar -xOzf dist/$ZIP $CFG")
  (devops-append-space))

(defun devops-section4-first-paragraph ()
  "Step in Section 4."
  (interactive)
  (goto-char (point-min))
  (when (not (search-forward "Install Python" nil t))
    (widen)
    (goto-char (point-min))
    (org-global-cycle 3)
    (search-forward "Install Python" nil t)
    (sit-for 4))

  (org-cycle 0)
  (org-narrow-to-subtree)

  (forward-line)
  (insert-typewriter "
    Need to make sure that the correct version of Python is installed
    on the server, but I suspected that we had already installed it.

    All of the following commands are executed on our deployment
    server, =minecraft.howardabrams.com=:")
  (org-set-property "dir" "/minecraft.howardabrams.com:")
  (search-backward "PROPERTIES")
  (org-cycle)
  (demo-it-message-keybinding "C-c C-x p" "org-set-property"))

(defun devops-section4-hostname ()
  "Step in Section 4."
  (interactive)
  (search-forward "server, =mine")
  (end-of-line)
  (insert-typewriter "

    <s")
  (sit-for 1)
  (org-cycle)
  (insert-typewriter "sh")
  (forward-line)
  (insert-typewriter "  hostname --long")
  (devops-append-space))

(defun devops-section4-update-hostname ()
  "Step in Section 4."
  (interactive)
  (search-backward "howardabrams.com=:")
  (end-of-line)
  (backward-char)
  (insert-typewriter ". Do we need to fix it so that
    it knows about its FQDN? I only get the hostname
    when I run"))

(defun devops-section4-python-check ()
  "Step in Section 4."
  (interactive)
  (goto-char (point-max))
  (insert-typewriter "    Here is the list of currently installed, python-related packages
    on the server:

    <s")
  (sit-for 1)
  (org-cycle)
  (insert-typewriter "sh")
  (forward-line 1)
  (end-of-line)
  (insert-typewriter "  sudo dpkg --get-selections | grep -v deinstall | egrep -i '^python\\b'")
  (devops-append-space))

(defun devops-section4-python-check-update ()
  "Step in Section 4."
  (interactive)
  (search-backward "BEGIN_SRC")
  (end-of-line)
  (insert-typewriter " :results table")
  (forward-line)
  (end-of-line)
  (insert-typewriter " | sed -e 's/\\s*install$//'"))

(defun devops-section4-insert-column1 ()
  "Step in Section 4."
  (interactive)
  (search-forward "RESULTS:")
  (org-cycle)
  (goto-char (point-max))
  (insert "
    #+NAME: column1
    #+BEGIN_SRC elisp :var data=\"\" :results value
      (mapcar 'car data)
    #+END_SRC
"))

(defun devops-section4-simple-python1 ()
  "Step in Section 4."
  (interactive)
  (search-backward "BEGIN_SRC" nil nil 2)
  (search-forward "table")
  (delete-char -5)
  (insert-typewriter "value list :post column1(data=*this*)")
  (search-forward "| sed")
  (backward-char 6)
  (kill-line)
  (highlight-regexp ":post column1(data=\\*this\\*)"))

(defun devops-section4-load-babeltower ()
  "Step in Section 4."
  (interactive)
  (unhighlight-regexp ":post column1(data=\\*this\\*)")
  (find-file "~/Work/dot-files/babel/tables.org"))

(defun devops-section4-load-babeltower-hi ()
  "Highlight the key code in the tower of babel."
  (interactive)
  (goto-char (point-min))
  (search-forward "#+NAME: table-filter")
  (beginning-of-line)
  (when (require 'fancy-narrow nil t)
    (fancy-narrow-to-region (point) (point-max)))
  (goto-char (point-max))
  (jump-backward "END_SRC")
  (recenter -1))

(defun devops-section4-simple-python2 ()
  "Step in Section 4."
  (interactive)
  (switch-to-buffer "sprint-fuzzy-bunny.org")
  (goto-char (point-max))
  (let ((start (point)) )
    (insert-typewriter "
    Called =dpkg= to get the list of currently installed,
    python-related packages on the server:

")
    (insert "    #+HEADER: :post table-filter(data=*this*, include=\"^python\", exclude=\"deinstall\")
    #+BEGIN_SRC sh :results value table
      dpkg --get-selections
    #+END_SRC
")
    (when (require 'fancy-narrow nil t)
      (fancy-narrow-to-region start (point-max))
      (sit-for 10)
      (fancy-widen))))

(defun devops-section4-complex-python ()
  "Step in Section 4."
  (interactive)
  (search-backward "table-filter")
  (insert-typewriter "column1(data=")
  (highlight-regexp "column1(data=")
  (end-of-line)
  (insert ")")
  (forward-line)
  (end-of-line)
  (delete-char -5)
  (insert-typewriter "list")
  (beginning-of-line 2))


(defun devops-back-to-presentation ()
  "Finish the demonstration and display the presentation."
  (interactive)
  (switch-to-buffer "presentation.org"))

(defun forward-notes-file ()
  "Clever approach to move the Presentation Notes forward in the buffer."
  (interactive)
  (let ((cb (buffer-name)) )
    (save-current-buffer
      (switch-to-buffer-other-frame "presentation-notes.org")
      (scroll-up-command))
    (switch-to-buffer-other-frame cb)))

;; ----------------------------------------------------------------------
;; Demonstration and/or Presentation Order

(defun devops-start-presentation ()
  "Simple Summary."
  (interactive)
  (demo-it-keybindings)

  (global-unset-key (kbd "<f1>"))
  (global-set-key (kbd "<f1>") 'demo-it-step)
  (global-set-key (kbd "C-<f1>") 'forward-notes-file)
  (global-set-key (kbd "A-<f1>") 'forward-notes-file)

  (demo-it-start (list
                  'devops-title-screen
                  'devops-load-presentation         ;; Frame 1
                  'devops-presentation-compare-files
                  'devops-presentation-compare-files-close
                  'devops-load-source-code          ;; Frame 2
                                        ; 'devops-sprint-snippet1
                  'devops-sprint-snippet2
                  'devops-sprint-snippet3
                  'devops-section1-1
                  'devops-section1-2
                  'devops-section1-3
                  'devops-section1-4
                  'devops-section1-4results
                  'devops-section1-4update

                  'devops-section1-highlight
                  'devops-section1-back-to-presentation

                  'devops-section1-5paragraph
                  'devops-section1-5insert-cd
                  'devops-section1-5dir-header
                  'devops-section1-6exports

                  'devops-section2-paragraph      ;; Optional stuff...
                  'devops-section2-sourcecode
                  'devops-section2-tangleheader

                  'devops-section3-start
                  'devops-section3-hide
                  'devops-section3-paragrah
                  'devops-section3-hideresults
                  'devops-section3-hi-dir
                  'devops-section3-removereporter
                  'devops-section3-nextparagraph

                  'devops-section3-nameblock
                  'devops-section3-tarparagraph
                  'devops-section3-redisplaytar
                  'devops-section3-tarcontentsdetails

                  'devops-section4-first-paragraph
                  'devops-section4-hostname
                  'devops-section4-update-hostname
                  'devops-section4-python-check
                  'devops-section4-python-check-update
                  'devops-section4-insert-column1
                  'devops-section4-simple-python1
                  'devops-section4-load-babeltower
                  'devops-section4-load-babeltower-hi
                  'devops-section4-simple-python2
                  'devops-section4-complex-python

                  'demo-it-presentation-return
                  'demo-it-end ) t))

;; ----------------------------------------------------------------------
;; Start the presentation whenever this script is evaluated. Good idea?
(devops-start-presentation)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; literate-devops-demo.el ends here

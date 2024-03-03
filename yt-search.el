;;; yt-search.el --- search youtube with yt-dlp and jq -*- lexical-binding: t -*-
;;
;; Author: kpm <kpm@linux.pl>
;; Created: 03 Mar 2024
;; Keywords: network, youtube
;;
;; It requires yt-dlp, jq and grep in PATH.
;;
;; Copyright (C) 2024 Krzysztof Michałczyk <kpm@linux.pl>
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are
;; met:
;;
;;     * Redistributions of source code must retain the above copyright
;; notice, this list of conditions and the following disclaimer.
;;     * Redistributions in binary form must reproduce the above
;; copyright notice, this list of conditions and the following disclaimer
;; in the documentation and/or other materials provided with the
;; distribution.
;;
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;; A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;; OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;; LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;; DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;; THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;;
;; This file is not part of GNU Emacs.

(defun yt-search--query (q)
  (shell-command-to-string (concat "yt-dlp ytsearch50:'" q "' --dump-json --default-search ytsearch "
                                   "--no-playlist --no-check-certificate --geo-bypass --flat-playlist "
                                   "--skip-download --quiet --ignore-errors "
                                   "| jq -r '[.uploader, .title, .url] | join(\"\\t\")'")))

(defvar yt-search--bufname "*yt-search*")

(defun yt-search (query)
  (interactive
   (list (read-string "Enter query: ")))
  (let* ((data (yt-search--query query))
         (lines (mapcar (lambda (s) (split-string s "\t")) (split-string data "\n"))))
    (with-current-buffer (get-buffer-create yt-search--bufname)
      (switch-to-buffer yt-search--bufname)
      (erase-buffer)
      (mapcar
       (lambda (l)
         (let* ((author-r (nth 0 l))
                (author (if (string-equal author-r "") "unknown" author-r))
                (title  (nth 1 l))
                (url    (nth 2 l)))
           (when (and (not (null author))
                      (not (null title))
                      (not (null url)))
             (insert-button
              "Watch"
              'face 'custom-button
              'follow-link t
              'action (lambda (_) (browse-url url)))

             (insert "\t")
             (put-text-property 0 (length author) 'face 'info-title-3 author)
             (insert author)
             (insert "\t")
             (put-text-property 0 (length title) 'face 'compilation-info title)
             (insert title)
             (insert "\n"))))
       lines)
      (goto-char (point-min)))))

(provide 'yt-search)

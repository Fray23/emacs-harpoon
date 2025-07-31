;;; harpoon.el --- Lightweight file bookmarking -*- lexical-binding: t; -*-

(defgroup harpoon nil
  "Project-aware file bookmarking."
  :group 'convenience
  :prefix "harpoon-")

(defcustom harpoon-project-scope-enabled t
  "Whether to use project-local harpoon list when in a project."
  :type 'boolean
  :group 'harpoon)

(defconst harpoon-global-storage-file
  (expand-file-name "harpoon-files.el" user-emacs-directory)
  "Global path to file storing the harpoon list.")

(defvar harpoon-list nil
  "List of marked files in harpoon.")

(defvar harpoon-buffer "*Harpoon*"
  "Buffer name for harpoon menu.")

(defvar harpoon--current-index 0
  "Internal pointer to current harpoon file index (0-based).")

(defun harpoon--project-root ()
  "Return the root of the current project, or nil."
  (when-let ((proj (project-current)))
    (project-root proj)))

(defun harpoon--storage-file (&optional project-aware)
  "Return the harpoon storage file path.
If PROJECT-AWARE is non-nil and inside a project, return project-local file."
  (if (and project-aware (harpoon--project-root))
      (expand-file-name ".harpoon-files.el" (harpoon--project-root))
    harpoon-global-storage-file))

(defun harpoon--save ()
  "Save the harpoon list to storage."
  (with-temp-file (harpoon--storage-file harpoon-project-scope-enabled)
    (prin1 harpoon-list (current-buffer))))

(defun harpoon--load ()
  "Load the harpoon list from storage."
  (setq harpoon-list nil)
  (let ((file (harpoon--storage-file harpoon-project-scope-enabled)))
    (when (file-exists-p file)
      (with-temp-buffer
        (insert-file-contents file)
        (setq harpoon-list (read (current-buffer)))))))

(defun harpoon-add ()
  "Add the current file to the harpoon list."
  (interactive)
  (harpoon--load)
  (let ((file (buffer-file-name)))
    (cond
     ((null file)
      (message "Current buffer is not visiting a file."))
     ((member file harpoon-list)
      (message "File already in harpoon: %s" file))
     (t
      (push file harpoon-list)
      (harpoon--save)
      (message "Added: %s" file)))))

(defun harpoon-remove ()
  "Remove the current file from the harpoon list."
  (interactive)
  (harpoon--load)
  (let ((file (buffer-file-name)))
    (when file
      (setq harpoon-list (remove file harpoon-list))
      (harpoon--save)
      (message "Removed: %s" file))))

(defun harpoon-clear ()
  "Clear all entries from harpoon with confirmation."
  (interactive)
  (when (yes-or-no-p "Are you sure you want to clear the harpoon list? ")
    (harpoon--load)
    (setq harpoon-list nil)
    (harpoon--save)
    (message "Harpoon list cleared.")))

(defun harpoon--shorten-path (file)
  "Return file path relative to project root, or full path if outside project."
  (let ((root (harpoon--project-root)))
    (if (and root (string-prefix-p root file))
        (string-remove-prefix root file)
      file)))

(defun harpoon--resolve-path (short-path)
  "Resolve relative path to full path using project root."
  (let ((root (harpoon--project-root)))
    (if root
        (expand-file-name short-path root)
      short-path)))

(defun harpoon-open-menu ()
  "Open harpoon selection menu."
  (interactive)
  (harpoon--load)
  (if (null harpoon-list)
      (message "Harpoon list is empty.")
    (let* ((choices (mapcar #'harpoon--shorten-path (reverse harpoon-list)))
           (selected (completing-read "Harpoon: " choices nil t))
           (full (harpoon--resolve-path selected)))
      (find-file full))))

(defun harpoon-remove-from-menu ()
  "Prompt for a file to remove from harpoon list."
  (interactive)
  (harpoon--load)
  (if (null harpoon-list)
      (message "Harpoon list is empty.")
    (let* ((choices (mapcar #'harpoon--shorten-path (reverse harpoon-list)))
           (selected (completing-read "Remove from Harpoon: " choices nil t))
           (full (harpoon--resolve-path selected)))
      (setq harpoon-list (remove full harpoon-list))
      (harpoon--save)
      (message "Removed: %s" selected))))

(defun harpoon--go-to (index)
  "Jump to harpoon file at INDEX (1-based)."
  (harpoon--load)
  (let* ((lst (reverse harpoon-list))
         (file (nth (1- index) lst)))
    (if file
        (progn
          (setq harpoon--current-index (1- index))
          (find-file file))
      (message "No harpoon entry at position %d" index))))

(defun harpoon-next ()
  "Jump to the next file in harpoon list."
  (interactive)
  (harpoon--load)
  (let ((lst (reverse harpoon-list))
        (len (length harpoon-list)))
    (if (zerop len)
        (message "Harpoon list is empty.")
      (setq harpoon--current-index (% (1+ harpoon--current-index) len))
      (find-file (nth harpoon--current-index lst)))))

(defun harpoon-prev ()
  "Jump to the previous file in harpoon list."
  (interactive)
  (harpoon--load)
  (let ((lst (reverse harpoon-list))
        (len (length harpoon-list)))
    (if (zerop len)
        (message "Harpoon list is empty.")
      (setq harpoon--current-index (mod (+ (1- harpoon--current-index) len) len))
      (find-file (nth harpoon--current-index lst)))))

(dotimes (i 9)
  (eval
   `(defun ,(intern (format "harpoon-go-to-%d" (1+ i))) ()
      ,(format "Jump to harpoon file %d" (1+ i))
      (interactive)
      (harpoon--go-to ,(1+ i)))))

(provide 'harpoon)

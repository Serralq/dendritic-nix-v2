;; Supplies the variables for the lsp server
((nix-mode . ((apheleia-formatter . nixfmt)))
 (nix-ts-mode . ((apheleia-formatter . nixfmt)))
 (nil . ((eval . (when (derived-mode-p 'nix-mode 'nix-ts-mode)
                  (let ((host (format "(builtins.getFlake %S).nixosConfigurations.hirakata"
                                      (directory-file-name
                                       (expand-file-name
                                        (locate-dominating-file default-directory ".dir-locals.el"))))))
                    (setq-local lsp-nix-nixd-nixpkgs-expr
                                (concat host ".pkgs")
                                lsp-nix-nixd-nixos-options-expr
                                (concat host ".options")
                                lsp-nix-nixd-home-manager-options-expr
                                (concat host ".options.home-manager.users.type.getSubOptions []"))))))))

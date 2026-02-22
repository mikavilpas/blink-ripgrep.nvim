# Changelog

## [2.2.4](https://github.com/mikavilpas/blink-ripgrep.nvim/compare/v2.2.3...v2.2.4) (2026-02-22)


### Bug Fixes

* allow disabling regex highlighting fallback for unknown filetypes ([9b8f85e](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/9b8f85ee4b2275c4dcf9b26c055ff7b5d4eadf8c))

## [2.2.3](https://github.com/mikavilpas/blink-ripgrep.nvim/compare/v2.2.2...v2.2.3) (2026-02-22)


### Bug Fixes

* informative error message when treesitter parser is missing ([969471a](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/969471a8ba61e86553c9091d507cb88008650371))

## [2.2.2](https://github.com/mikavilpas/blink-ripgrep.nvim/compare/v2.2.1...v2.2.2) (2025-12-21)


### Bug Fixes

* remove upstreamed fix for unmodifiable documentation window ([#505](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/505)) ([fc5ebb4](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/fc5ebb434d5afa9095e4ef8ef035672b9642f1e1))

## [2.2.1](https://github.com/mikavilpas/blink-ripgrep.nvim/compare/v2.2.0...v2.2.1) (2025-12-19)


### Bug Fixes

* handle unmodifiable documentation window ([#499](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/499)) ([473be84](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/473be84be965bf53c59d79215bf63f505ecd0b0a))

## [2.2.0](https://github.com/mikavilpas/blink-ripgrep.nvim/compare/v2.1.0...v2.2.0) (2025-10-26)


### Features

* allow passing `additional_gitgrep_options` to git-grep backend ([#426](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/426)) ([210b6ef](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/210b6ef735dcea429804dece28ec6c5962ba1e0c))

## [2.1.0](https://github.com/mikavilpas/blink-ripgrep.nvim/compare/v2.0.1...v2.1.0) (2025-10-16)


### Features

* **health:** show ripgrep version in health check ([aea46a6](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/aea46a603d76b08c6dc0000ea2927a39cc6c36a3))

## [2.0.1](https://github.com/mikavilpas/blink-ripgrep.nvim/compare/v2.0.0...v2.0.1) (2025-10-12)


### Bug Fixes

* bump version to 2.0.0 ([#379](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/379)) ([2d26eb2](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/2d26eb252745d1670e64656657d9f34d158fd25f))

## [2.0.0](https://github.com/mikavilpas/blink-ripgrep.nvim/compare/v1.0.0...v2.0.0) (2025-10-12)


### ⚠ BREAKING CHANGES

* The configuration format has changed. Previously an automatic migration was done, but now the user must migrate their config manually.

### Features

* remove config migration and use new config format only ([#378](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/378)) ([372fab1](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/372fab131330eb697c730e42d6e35a7c68167fbf))


### Bug Fixes

* **deps:** update all non-major dependencies ([#323](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/323)) ([a89eed1](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/a89eed1e48859bc59d9e0ba729727a885f24fb67))

## [1.0.0](https://github.com/mikavilpas/blink-ripgrep.nvim/compare/v1.0.0...v1.0.0) (2025-08-10)


### ⚠ BREAKING CHANGES

* clearly support backend specific options ([#256](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/256))
* render the context preview lazily, not immediately
* The `get_command` function, which provides a custom way to generate the entire ripgrep command, must now return a table with the command and the root path.
* The label will no longer show "(rg)" by default for blink-ripgrep results. If you want to preserve the previous behavior, you can copy the `transform_items` option from the README to your configuration.
* highlight the match context with treesitter ([#22](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/22))
* rename project to blink-ripgrep.nvim

### Features

* add a debug mode that prints the rg command that was used ([96bf52c](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/96bf52cd405d16ed6474302b21b38778dc5a7b38))
* add additional_paths option to search in additional dirs/files ([519ac78](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/519ac7894113f6a7b517b157c26e31fbd58a0de5))
* add checkhealth script ([9b46e4f](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/9b46e4fa81ca1b3a73b676741eb466b02f2b1d73))
* add health check for blink-cmp-rg ([6514423](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/65144236503203f63046eb9f0a4b2094c7b21817))
* add lua_ls types for the plugin's options ([#3](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/3)) ([16598dd](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/16598dd1c47c1f5ef163d552ac1c5d66e886f8dd))
* add workaround for issue with documentation ([7bec1b6](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/7bec1b61233cc81384eda181d099370a8282218b))
* allow canceling the search with `project_root_fallback = false` ([#112](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/112)) ([c693690](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/c6936902a29ee41493c09b174b08ec3f95ab722b))
* allow customizing the search casing for ripgrep ([#66](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/66)) ([2ec6aef](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/2ec6aef3517b83659fdaef57b4b1fd4ed41e9692))
* allow flexible configuration of the project root ([#70](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/70)) ([78e1e89](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/78e1e89f2306bf707fdd0b668b61a313e27f1144))
* allow passing `additional_rg_options` to ripgrep ([#57](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/57)) ([bce6c51](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/bce6c517d24dfa24fec862ad79f0aa85d0b95e85))
* allow specifying the number of lines to show around each match ([4a449cb](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/4a449cb3f7cb28b63fbd1d6d93e02008aa59cb09))
* allow using gitgrep or ripgrep based on the current directory ([#178](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/178)) ([4d8cc19](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/4d8cc19ca63a8236d6c9da384e2d7b0f63517069))
* blink displays text CompletionItemKind for results ([#84](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/84)) ([51aa53a](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/51aa53a2ec044ea6c6ed61d6ac8e68f4aa940482))
* can find words that include special characters ([81cc172](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/81cc172f44bec0ad0981f17d7547e03b0aacc105))
* config ([98bf68d](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/98bf68dcf9de6ff3125f5089898716a26016a8a2))
* **debug,opt-in:** temporarily highlight the search prefix ([#95](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/95)) ([7854eee](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/7854eeedf478f3eaf2c22d7bbb2dad16c2b12153))
* display context for matches as documentation ([c21f1ed](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/c21f1ed685d0fee7a8a7dc29bd24fad39b01546e))
* don't show "(rg)" in the label by default ([#83](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/83)) ([0940212](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/09402126fa63afa991947132f68ede6f1239c4ac))
* enable toggling the plugin on/off with folke/snacks.nvim ([#123](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/123)) ([eea5060](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/eea5060f45dd8ca4fec8be25f6a4c0c2ff04dbf5))
* fall back to regex highlighting when treesitter not available ([#65](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/65)) ([a7bc8fd](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/a7bc8fd1743a6fda645756fd498c738d15637072))
* **git,opt-in:** experimental git grep backend ([#142](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/142)) ([909eec8](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/909eec82d2d48190541d282e5eff4cf7d06693b3))
* **git:** always use `--recurse-submodules` ([081985f](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/081985f9110f0183d27e26f3ae90dd9f62c7c349))
* highlight the match context with treesitter ([#22](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/22)) ([96e3fb5](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/96e3fb539d7abb55f16b04aea5ebcedb1acc7b28))
* highlight the match in the documentation window ([#74](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/74)) ([9827f17](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/9827f17d9b1bb443327ef97ff6b66c8745d67775))
* ignore case ([efff62b](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/efff62ba875f3fa77a7bce7ae315e807b7e00909))
* init project ([4a04bec](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/4a04bece758913ec0a4ee87dfc6a5ac75485f579))
* make it easy to see which matches are from rg ([8d64505](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/8d6450596cb6bfdb078b7069d8273966dc0b2fee))
* more options ([aa27e72](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/aa27e728222034de4e4f642d397fd849481de8f2))
* move toggle keymaps to stable features ([9c6ab71](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/9c6ab71b0a4131106f81372d7dff57c48de621b2))
* **opt-in:** kill previous searches when a new search is started ([#100](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/100)) ([705069a](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/705069a57566a5e7427025264451c581f0bfb9c4))
* **opt-in:** toggle debug mode on/off for quick plugin debugging ([#226](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/226)) ([92f9e5f](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/92f9e5fbc871cfe742195de3f6c89ab39421d3a4))
* option ignore_paths to avoid running on certain paths ([#105](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/105)) ([0882f96](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/0882f96daf940c4d17358aa76f3ccf213a7df3b2))
* **performance:** max_filesize option (def: 1M) skips large files ([#41](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/41)) ([1cfaf8d](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/1cfaf8db14fdba802886a7bd30c1ae49dba93a91))
* remove issue185_workaround as it is no longer needed ([8bc8c07](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/8bc8c07ada9a456d9b87b003c4732537f309ee74))
* rg source completion ([755594b](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/755594ba7fafd08d2eff94e3f00056eae6369fbe))
* show the file name where the match came from ([#10](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/10)) ([0c369d8](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/0c369d8f4f409b170a95a0370b999674010082e6))
* show the matched lines as documentation for context ([76676af](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/76676af8b964d48fbe131882c851da6e238e7edd))
* support multiple matches on the same line in ripgrep backend ([65a3c69](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/65a3c6974fe310ee457f79b81ec72b64d0ec02f1))
* the default context size is now 3 -&gt; 5 ([#30](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/30)) ([a12a60b](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/a12a60ba54398c980f78f488219f28ce5860ea6e))
* use unique kind icons (git/ripgrep) and allow colorizing them ([9f96838](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/9f968385bbed53b5996723ae28ca509eb1d4381e))


### Bug Fixes

* **#2:** wrong opts ([168aeb5](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/168aeb5d361081da6fbdf810de3266d41d2a1165))
* complicated initialization of the toggling feature ([61c7dcf](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/61c7dcfebc764ae0aa981a9216bbcfd2630f513e))
* correctly use `--ignore-case` ([c8f8e4b](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/c8f8e4b5a803e3d1c95652876c94b113ee08b146))
* crash when no options are provided ([#54](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/54)) ([70a5a17](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/70a5a17b951950335d8277b8dbf20927dcbee60f))
* git grep showing wrong part of the match as highlighted ([#276](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/276)) ([bdc1e90](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/bdc1e90da30bf34d6c5551ee49cb7ad4a7ba3428))
* hide any errors about highlighting ([252a44a](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/252a44ae71cabc5f625ca0d91703d4ea3059d4bd))
* ignore_paths not working outside of debug mode ([#113](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/113)) ([db1fa9c](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/db1fa9c4321172dd70b13b1ef292bb1d923e87dc))
* issues with default `rg` command ([da81310](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/da81310760e5c14241f19c93e32f8c3cc31fe7f3))
* issues with default `rg` command ([6b721f2](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/6b721f2da7abe1a13daee69675040b8b8c938187))
* make `kind_name` less technical ([2c87814](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/2c87814a1ac19447330ecc760d231a91f6789bfb))
* not providing completions for a project root with spaces ([#87](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/87)) ([79fb538](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/79fb538d06c38a108a1d251552a9f3fc3b80a491))
* prefix_min_len ([b657d3b](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/b657d3bff3536c8e6e0bb399a8a0fe839ea2f9df))
* **prefix:** don't include `-` or `_` at the start of the word ([#31](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/31)) ([2f00bb0](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/2f00bb08e498061ee72754de1ac46845ff2377e8))
* random blink crash due to E5560 (fast event context) ([1310286](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/1310286ad9ffd9261b0dd70024ce927a0dc660e3))
* support directories with spaces ([d46aaf8](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/d46aaf82f9dcf675a44fff58b7fdf9248ab20f9c))
* **tests:** failing on repeated invocations at existing directories ([7d27d6b](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/7d27d6bf41d0364ef4baf5a93efa630f75a0a7ff))
* the doc separator line should be the ~width of the window ([b6c7702](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/b6c77026ad126a4cf5a075da6a07ea795fd4200e))
* typecheck error due to new blink.cmp API ([ca538d1](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/ca538d15bd22fedd3408064d2b25ff8d56ec8ce8))
* **types:** max_filesize should be a string, not a number ([#47](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/47)) ([ffff6cc](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/ffff6cca96568ab8407613d9e9caee1a9144873c))
* **types:** update types for get_command and get_prefix ([#5](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/5)) ([b27eb5d](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/b27eb5dc681fd7a4dcf7981d9eeb9980de50d233))
* **types:** use the correct parameter name ([d79688f](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/d79688fbdda26476a4bc15c4afa85cd2a189eaa2))
* use .git instead of git directory as the root ([17548b7](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/17548b762717844d04d59f39e2259a52bfbd4bc5))
* use .git instead of git directory as the root ([dcb9ff6](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/dcb9ff6ca89d6e8752051b3c685ff0a4ac26ff4f))
* use .git instead of git directory as the root ([6b0aafd](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/6b0aafdf57b199ec0d88266e772b1935ef2defc3))


### Performance Improvements

* assertions don't need to needlessly convert each item to strings ([9a04e40](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/9a04e40ec7d72fff233e893e8287b1a8d8bc7332))
* avoid blocking the main thread in GitGrepOrRipgrepBackend ([af61f99](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/af61f99945e15b195fbce017230cedb0497ded4d))
* kill previous ripgrep searches when a new search is started ([#106](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/106)) ([8df7edd](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/8df7edd8569ce18b3cae47290c8766a46a9b1cb6))
* only collect the necessary context preview for each match ([#49](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/49)) ([4f1c63e](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/4f1c63eb84a94ad463e76b20cb0dda657a1bedbf))
* only register each unique match once ([#46](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/46)) ([1d57681](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/1d576810c33b5c11022e5865a24d66e0d8f0f1ca))
* remove extra map/filter in RgSource:get_completions ([#4](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/4)) ([df013b4](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/df013b470e3da01a0b9ece1b6c5689b857c66f63))
* remove unused context size from ripgrep command ([e45cb2c](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/e45cb2cb444ea909574b509e9719e23988ee9348))
* skip processing result words that already exist ([#50](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/50)) ([796cc24](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/796cc24bb56cda813f768d6bd6aed12c32ad93b4))


### Miscellaneous Chores

* prettier ignores CHANGELOG.md ([cb1798d](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/cb1798d774d69f35c35eb6e2d23a4f2d1d73af31))


### Code Refactoring

* clearly support backend specific options ([#256](https://github.com/mikavilpas/blink-ripgrep.nvim/issues/256)) ([7bdf467](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/7bdf467bee22ea3e61b0c76d8f8feb6deaffcd16))
* rename project to blink-ripgrep.nvim ([94ab08a](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/94ab08afe39223b087c3002a4d2d296da10e6e86))
* render the context preview lazily, not immediately ([9d1351f](https://github.com/mikavilpas/blink-ripgrep.nvim/commit/9d1351f4f226b3ea65c84141279cbe80098c30af))

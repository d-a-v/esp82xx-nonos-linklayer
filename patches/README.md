# Patches

- Initialize a clean lwip2-src with the required base ref
  ```console
  $ gmake LWIP_REF=refs/tags/STABLE-1_2_3_RELEASE checkout
  ```
- Switch to a temporary branch to work with patch tools
  ```console
  $ cd lwip2-src/
  $ git clean -f -x -d               # currently, STABLE-1_2_3_RELEASE
  $ git checkout -b my-patch-series  # new branch, starting from STABLE-1_2_3_RELEASE
  ```
- Apply every patch listed in [`series`](series), top to bottom. Each patch file becomes a single commit.
  - For example, using [`stgit`](https://stacked-git.github.io/guides/tutorial/#importing-patches)
    ```console
    $ cd lwip2-src/
    $ git reset --hard STABLE-1_2_3_RELEASE  # undo any previously applied commits
    $ git config stgit.namelength 0          # do not apply character limit to filenames
    $ stg import --series ../patches/series  # apply patch series to the working tree and index
    ```
- Refresh existing patch series, remove from it or add any new patches.
  See https://stacked-git.github.io/guides/tutorial/ for the full `stg` tutorial.
- Export patch series files back into the repo
  ```console
  $ cd lwip2-src/
  $ stg export --dir ../patches/series --template ../patches/series.tmpl
  ```

# Other useful links

- https://github.com/git-guilt/guilt for the `guilt` tool, alternative to `stg` which also works on existing git tree
- https://honk.sigxcpu.org/projects/git-buildpackage/manual-html/gbp.patches.html for an example of debian buildpackage tool

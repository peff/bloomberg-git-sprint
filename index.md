---
center

# Getting Started Hacking on Git

Bloomberg Git Sprint  
Jeff King  
Nov 11-12, 2017

---
center

# Getting Git

    $ git clone https://github.com/git/git

---
center

# Building Git

Ideally:

    $ make

There's autoconf support, but it is usually not necessary.

---
center

# Build-time knobs

    $ make CFLAGS='-O0 -g -Wall -Werror'
    $ make USE_LIBPCRE=Yes

or

    $ echo USE_LIBPCRE=Yes >config.mak
    $ make

See `Makefile` for the full list.

---
center

# Testing Git

Build and run all tests:

    $ make test

Run an individual test script:

    $ cd t
    $ ./t4201-log.sh

Debugging a test:

    $ ./t4201-log.sh -v -i -x

---
center

# Overview of Git

History is just a directed acyclic graph over a set of
content-addressable objects.

<img src="gollum.gif" height="50%">

---
center

# Git in Five Easy Slides

Further reading:

  https://git-scm.com/book/en/v2

  https://git-scm.com/book/en/v2/Git-Internals-Git-Objects

---
small center

Most data in git is stored in objects named after their sha1. Objects
refer to each other by sha1 names:

    $ echo foo | git hash-object --stdin
    257cc5642cb1a054f08cc83f2d943e56fd3ebe99

    $ git ls-tree -rt --abbrev 8fb5eb437957
    100644 blob 257cc5642cb1	file
    040000 tree 56a4e0993737	subdir
    100644 blob 5716ca5987cb	subdir/another-file

    $ git cat-file commit d38a39c44
    tree 8fb5eb437957edd0fafb56fc678fa1dc3b5b63ba
    parent 7034f601209422783ebcd02d9afca886f6203fe9
    author Jeff King <peff@peff.net> 1510384149 +0000
    committer Jeff King <peff@peff.net> 1510384149 +0000

    this is the commit message

---
center

Refs map human-usable names to objects:

    $ cat .git/refs/heads/master
    d38a39c44433f36a0e52dcae78e00358f104bf28

    $ cat .git/HEAD
    ref: refs/heads/master

---

Most git commands are operations to modify or query objects or refnames.

- `git commit`:
  - create blob objects for all files
  - create hierarchy of trees pointing to blobs
  - create commit object:
      - tree points to newly created tree
      - parent points to current `HEAD`
      - collect commit message from user
  - update `HEAD` to point to new commit

---

- `git log`:
  - resolve ref names to commit objects
  - traverse parent pointers, visiting each commit
  - show author, commit message, etc
  - show diff between commit and its parent

---
center

High-level user-facing commands are called _porcelain_.

These can be implemented in terms of low-level commands called
_plumbing_.

`git log master`:

    start=$(git rev-parse master)
    for commit in $(git rev-list $start); do
      git cat-file commit $commit
      git diff-tree -p $commit^ $commit
    done

---

# Exploring Git's Code

 - explore top-down
 - plumbing commands are often more clear and expose internals
 - the "main()" for _git foo_ is in `cmd_foo()`, usually in `builtin/foo.c`
 - support code for a concept is in `foo.[ch]`
   - except `cache.h` is a dumping ground for some headers
 - documentation for APIs in header files
 - some older documentation in `Documentation/technical`

---

# APIs

 - making C less difficult:
   - strbuf.[ch] -- dynamic string buffer
   - string_list.[ch] -- dynamic list of strings
   - ALLOC_GROW() -- dynamic arrays
   - hashmap.[ch] -- key/value store
   - run-command.[ch] -- portably spawning sub-programs

---

# APIs

 - Git-specific APIs
   - config.[ch] -- reading/writing config files
   - sha1_name.c -- resolving object names
   - sha1_file.c -- reading/writing object data
   - revision.[ch] -- traversing commit graph
   - diff.[ch] -- diffs between trees
   - {object,commit,tree,blob}.h -- in-memory representation of objects

---
center

# "Object-oriented" C

    /* Declare an object (with an initializer) */
    struct strbuf msg = STRBUF_INIT;

    /* Call a "method" */
    strbuf_addstr(&msg, "a string");

    /* Direct access to stuct members is normal */
    foo(msg.buf);

    /* Manual "destructor" */
    strbuf_release(&msg);

---
center

A lot of older code is `verb_noun` (or apparently random):

    struct rev_info revs;
    init_revisions(&revs);
    setup_revisions(argc, argv, &revs, &opts);
    while ((commit = get_revision(&revs)) {
      pretty_print_commit(&context, commit, &buf);
    }

Usually related functions are grouped in the header files.

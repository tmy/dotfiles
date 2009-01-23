#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright (c) 2005, Giovanni Bajo
# Copyright (c) 2004-2005, Awarix, Inc.
# All rights reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
#
# Author: Archie Cobbs   archie at awarix dot com
# Rewritten in Python by: Giovanni Bajo  rasky at develer dot com
#
# Acknowledgments:
#   John Belmonte <john at neggie dot net> - metadata and usability
#     improvements
#   Blair Zajac <blair at orcaware dot com> - random improvements
#
# $HeadURL: http://svn.collab.net/repos/svn/branches/1.3.x/contrib/client-side/svnmerge.py $
# $LastChangedDate: 2005-11-16 01:57:56 +0100 (Wed, 16 Nov 2005) $
# $LastChangedBy: maxb $
# $LastChangedRevision: 17383 $
#
# Differences from official svnmerge:
# - More portable: tested as working in FreeBSD and OS/2.
# - Add double-verbose mode, which shows every svn command executed (-v -v).
# - "svnmerge avail" now only shows commits in head, not also commits in other
#   parts of the repository.
# - Add "svnmerge block" to flag some revisions as blocked, so that
#   they will not show up anymore in the available list.  Added also
#   the complementary "svnmerge unblock".
# - "svnmerge avail" has grown two new options:
#   -B to display a list of the blocked revisions
#   -A to display both the the blocked and the available revisions.
# - Improved generated commit message to make it machine parsable even when
#   merging commits which are themselves merges.
# - Add --force option to skip working copy check
#
# TODO:
#  - Add "svnmerge avail -R": show logs in reverse order

import sys, os, getopt, re, types, popen2

NAME="svnmerge"
if not hasattr(sys, "version_info") or sys.version_info < (2, 0):
    print "%s requires Python 2.0 or newer" % NAME
    sys.exit(1)

# Set up the separator used to separate individual log messages from
# each revision merged into the target location.  Also, create a
# regular expression that will find this same separator in already
# committed log messages, so that the separator used for this run of
# svnmerge.py will have one more LOG_SEPARATOR appended to the longest
# separator found in all the commits.
LOG_SEPARATOR = 8 * '.'
LOG_SEPARATOR_RE = re.compile('^((%s)+)' % re.escape(LOG_SEPARATOR),
                              re.MULTILINE)

# We expect non-localized output from SVN
os.environ["LC_MESSAGES"] = "C"

###############################################################################
# Support for older Python versions
###############################################################################

# True/False constants are Python 2.2+
try:
    True, False
except NameError:
    True, False = 1, 0

def lstrip(s, ch):
    """Replacement for str.lstrip (support for arbitrary chars to strip was
    added in Python 2.2.2)."""
    i = 0
    try:
        while s[i] == ch:
            i = i+1
        return s[i:]
    except IndexError:
        return ""

def rstrip(s, ch):
    """Replacement for str.rstrip (support for arbitrary chars to strip was
    added in Python 2.2.2)."""
    if s[-1] != ch:
        return s
    i = -2
    try:
        while s[i] == ch:
            i = i-1
        return s[:i+1]
    except IndexError:
        return ""

def strip(s, ch):
    """Replacement for str.strip (support for arbitrary chars to strip was
    added in Python 2.2.2)."""
    return lstrip(rstrip(s, ch), ch)

def rsplit(s, sep, maxsplits=0):
    """Like str.rsplit, which is Python 2.4+ only."""
    L = s.split(sep)
    if not 0 < maxsplits <= len(L):
        return L
    return [sep.join(L[0:-maxsplits])] + L[-maxsplits:]

###############################################################################

def kwextract(s):
    """Extract info from a svn keyword string."""
    try:
        return strip(s, "$").strip().split(": ")[1]
    except IndexError:
        return "<unknown>"

SRCREV=kwextract('$Rev: 17383 $')
SRCDATE=kwextract('$Date: 2005-11-16 01:57:56 +0100 (Wed, 16 Nov 2005) $')

# Additional options, not (yet?) mapped to command line flags
opts = {
    "svn": "svn",
    "prop": NAME + "-integrated",
    "block_prop": NAME + "-blocked",
    "commit_verbose": True,
}

def console_width():
    """Get the width of the console screen (if any)."""
    try:
        return int(os.environ["COLUMNS"])
    except (KeyError, ValueError):
        pass

    try:
        # Call the Windows API (requires ctypes library)
        from ctypes import windll, create_string_buffer
        h = windll.kernel32.GetStdHandle(-11)
        csbi = create_string_buffer(22)
        res = windll.kernel32.GetConsoleScreenBufferInfo(h, csbi)
        if res:
            import struct
            (bufx, bufy, curx, cury, wattr,
             left, top, right, bottom, maxx, maxy) = struct.unpack("hhhhHhhhhhh", csbi.raw)
            return right - left + 1
    except ImportError:
        pass

    # sensible default
    return 80

def error(s):
    """Subroutine to output an error and bail."""
    print "%s: %s" % (NAME, s)
    sys.exit(1)

def report(s):
    """Subroutine to output progress message, unless in quiet mode."""
    if opts["verbose"]:
        print "%s: %s" % (NAME, s)

class LaunchError(Exception):
    """Signal a failure in execution of an external command. Parameters are the
    exit code of the process, the original command line, and the output of the
    command."""

def launch(cmd, split_lines=True):
    """Launch a sub-process. Return its output (both stdout and stderr),
    optionally split by lines (if split_lines is True). Raise a LaunchError
    exception if the exit code of the process is non-zero (failure)."""
    if os.name not in ['nt', 'os2']:
        p = popen2.Popen4(cmd)
        p.tochild.close()
        if split_lines:
            out = p.fromchild.readlines()
        else:
            out = p.fromchild.read()
        ret = p.wait()
        if ret == 0:
            ret = None
        else:
            ret >>= 8
    else:
        i,k = os.popen4(cmd)
        i.close()
        if split_lines:
            out = k.readlines()
        else:
            out = k.read()
        ret = k.close()

    if ret is None:
        return out
    raise LaunchError(ret, cmd, out)

def launchsvn(s, show=False, pretend=False, **kwargs):
    """Launch SVN and grab its output."""
    cmd = opts["svn"] + " " + s
    if show or opts["verbose"] >= 2:
        print cmd
    if pretend:
        return None
    return launch(cmd, **kwargs)

def svn_command(s):
    """Do (or pretend to do) an SVN command."""
    out = launchsvn(s, show=opts["show_changes"] or opts["dry_run"],
                    pretend=opts["dry_run"],
                    split_lines=False)
    if not opts["dry_run"]:
        print out

def check_dir_clean(dir):
    """Check the current status of dir for up-to-dateness and local mods."""
    if opts["force"]:
        report('skipping status check because of --force')
        return
    report('checking status of "%s"' % dir)
    for L in launchsvn("status -q %s" % dir):
        if L:
            error('"%s" has local modifications; it must be clean' % dir)
    for L in launchsvn("status -u %s" % dir):
        if L[7] == '*':
            error('"%s" is not up to date; please "svn update" first' % dir)

class RevisionList:
    """
    A set of revisions, held in dictionary form for easy manipulation. If we
    were to rewrite this script for Python 2.3+, we would subclass this from
    set (or UserSet).
    """
    def __init__(self, parm):
        """Constructs a RevisionList from a string in property form, or from
        a dictionary whose keys are the revisions. Raises ValueError if the
        input string is invalid."""
        if isinstance(parm, types.DictType):
            self._revs = parm.copy()
            return

        self._revs = {}
        parm = parm.strip()
        if parm:
            for R in parm.split(","):
                if "-" in R:
                    s,e = R.split("-")
                    for rev in range(int(s), int(e)+1):
                        self._revs[rev] = 1
                else:
                    self._revs[int(R)] = 1

    def normalized(self):
        """Returns a normalized version of the revision list, which is an
        ordered list of couples (start,end), with the minimum number of
        intervals."""
        revnums = self._revs.keys()
        revnums.sort()
        revnums.reverse()
        ret = []
        while revnums:
            s = e = revnums.pop()
            while revnums and revnums[-1] in (e, e+1):
                e = revnums.pop()
            ret.append((s, e))
        return ret

    def __str__(self):
        """Convert the revision list to a string, using its normalized form."""
        L = []
        for s,e in self.normalized():
            if s == e:
                L.append(str(s))
            else:
                L.append(str(s) + "-" + str(e))
        return ",".join(L)

    def __contains__(self, rev):
        return self._revs.has_key(rev)

    def __sub__(self, RL):
        """Compute subtraction as in sets."""
        revs = {}
        for r in self._revs.keys():
            if r not in RL:
                revs[r] = 1
        return RevisionList(revs)

    def __and__(self, RL):
        """Compute intersections as in sets."""
        revs = {}
        for r in self._revs.keys():
            if r in RL:
                revs[r] = 1
        return RevisionList(revs)

    def __nonzero__(self):
        return bool(self._revs)

    def __iter__(self):
        revnums = self._revs.keys()
        revnums.sort()
        return iter(revnums)

    def __or__(self, RL):
        """Compute set union."""
        revs = self._revs.copy()
        revs.update(RL._revs)
        return RevisionList(revs)

def get_revlist_prop(dir, propname):
    """Extract the values of a property which store per-head revision lists,
    as a dictionary: key is a relative path to a head (in the repository), and
    value is the integrated revisions for that head."""
    prop = {}

    # Note that propget does not return error if the property does not exist:
    # it simply does not output anything. So we do not need to check for
    # LaunchError here.
    out = launchsvn('propget "%s" "%s"' % (propname, dir),
                    split_lines=False)

    # multiple heads are separated by any whitespace
    for L in out.split():
        # We use rsplit to play safe and allow colons in paths
        head, revs = rsplit(L.strip(), ":", 1)
        prop[head] = revs
    return prop

def get_merge_props(dir):
    """Extract the merged revisions."""
    return get_revlist_prop(dir, opts["prop"])

def get_block_props(dir):
    """Extract the blocked revisions."""
    return get_revlist_prop(dir, opts["block_prop"])

def get_blocked_revs(dir, head_path):
    p = get_block_props(dir)
    if p.has_key(head_path):
        return RevisionList(p[head_path])
    return RevisionList("")

def format_merge_props(props, sep=" "):
    assert sep in ["\t", "\n", " "]   # must be a whitespace
    props = props.items()
    props.sort()
    L = []
    for h,r in props:
        L.append(h + ":" + r)
    return sep.join(L)

def set_merge_props(dir, props):
    props = format_merge_props(props)
    svn_command('propset "%s" "%s" "%s"' % (opts["prop"], props, dir))

def set_blocked_revs(dir, head_path, revs):
    props = get_block_props(dir)
    if revs:
        props[head_path] = str(revs)
    else:
        if props.has_key(head_path):
            del props[head_path]
    props = format_merge_props(props)
    if props:
        svn_command('propset "%s" "%s" "%s"' % (opts["block_prop"], props, dir))
    else:
        svn_command('propdel "%s" "%s"' % (opts["block_prop"], dir))

def is_url(url):
    """Check if url is a valid url."""
    return re.search(r"^[a-zA-Z][-+\.\w]*://", url) is not None

def is_wc(dir):
    """Check if a directory is a working copy."""
    return os.path.isdir(dir) and os.path.isdir(os.path.join(dir, ".svn"))

_cache_svninfo = {}
def get_svninfo(path):
    """Extract the subversion information for a path (through 'svn info').
    This function uses an internal cache to let clients query information
    many times."""
    global _cache_svninfo
    if path in _cache_svninfo:
        return _cache_svninfo[path]
    info = {}
    for L in launchsvn('info "%s"' % path):
        L = L.strip()
        if not L:
            continue
        key, value = L.split(": ", 1)
        info[key] = value.strip()
    _cache_svninfo[path] = info
    return info

def target_to_url(dir):
    """Convert working copy path or repos URL to a repos URL."""
    if is_wc(dir):
        info = get_svninfo(dir)
        return info["URL"]
    return dir

def get_repo_root(dir):
    """Compute the root repos URL given a working-copy path or an URL."""
    url = target_to_url(dir)
    assert url[-1] != '/'

    # Try using "svn info URL". This works only on SVN clients >= 1.2
    try:
        info = get_svninfo(url)
        return info["Repository Root"]

    except LaunchError:
        # Constrained to older svn clients, we are stuck with this ugly
        # trial-and-error implementation. It could be made faster with a
        # binary search.
        while url:
            temp = os.path.dirname(url)
            try:
                launchsvn('proplist "%s"' % temp)
            except LaunchError:
                return url
            url = temp
        assert 0, "svn repos root not found"

def url_to_rlpath(dir):
    """Convert a repos URL into a repo-local path."""
    root = get_repo_root(dir)
    assert root[-1] != "/"
    assert dir[:len(root)] == root, "dir=%r, root=%r" % (dir, root)
    return dir[len(root):]

def get_copyfrom(dir):
    """Get copyfrom info for a given target (it represents the directory from
    where it was branched). NOTE: repos root has no copyfrom info. In this case
    None is returned."""
    rlpath = url_to_rlpath(target_to_url(dir))
    out = launchsvn('log -v --xml --stop-on-copy "%s"' % dir, split_lines=False)
    out = out.replace("\n", " ")
    m = re.search(r'(<path .*action="A".*>%s</path>)' % rlpath, out)
    if not m:
        return None,None
    head = re.search(r'copyfrom-path="([^"]*)"', m.group(1)).group(1)
    rev = re.search(r'copyfrom-rev="([^"]*)"', m.group(1)).group(1)
    return head,rev

def get_latestrev(url):
    """Get the latest revision of the repository of which URL is part."""
    try:
        return get_svninfo(url)["Revision"]
    except LaunchError:
        # Alternative method for latest revision checking (for svn < 1.2)
        report('checking latest revision of "%s"' % url)
        L = launchsvn('proplist --revprop -r HEAD "%s"' % opts["head_url"])[0]
        rev = re.search("revision (\d+)", L).group(1)
        report('latest revision of "%s" is %s' % (url, rev))
        return rev

def get_commit_log(url, revnum):
    """Return the log message for a specific integer revision
    number."""
    out = launchsvn("log --incremental -r%d %s" % (revnum, url))
    return "".join(out[1:])

def construct_merged_log_message(url, revnums):
    """Return a commit log message containing all the commit messages
    in the specified revisions at the given URL.  The separator used
    in this log message is determined by searching for the longest
    svnmerge separator existing in the commit log messages and
    extending it by one more separator.  This results in a new commit
    log message that is clearer in describing merges that contain
    other merges."""
    logs = ['']
    longest_sep = ''
    for r in revnums:
        message = get_commit_log(opts["head_url"], r)
        logs.append(message)
        for match in LOG_SEPARATOR_RE.findall(message):
            sep = match[1]
            if len(sep) > len(longest_sep):
                longest_sep = sep

    longest_sep += LOG_SEPARATOR + "\n"
    logs.append('')
    return longest_sep.join(logs)

def get_default_head(branch_dir, branch_props):
    """Return the default head for branch_dir (given its branch_props). Error
    out if there is ambiguity."""
    if not branch_props:
        error("no integration info available")

    props = branch_props.copy()
    dir = target_to_url(branch_dir)
    dir = url_to_rlpath(dir)

    # To make bi-directional merges easier, find the target's
    # repository local path so it can be removed from the list of
    # possible integration sources.
    if props.has_key(dir):
        del props[dir]

    if len(props) > 1:
        error('multiple heads found. Explicit head argument (-S/--head) required.')

    return props.keys()[0]

def check_old_prop_version(branch_dir, props):
    """Check if props (of branch_dir) are svnmerge properties in old format,
    and emit an error if so."""
    # Previous svnmerge versions allowed trailing /'s in the repository
    # local path.  Newer versions of svnmerge will trim trailing /'s
    # appearing in the command line, so if there are any properties with
    # trailing /'s, they will not be properly matched later on, so require
    # the user to change them now.
    fixed = {}
    changed = False
    for head, revs in props.items():
        h = rstrip(head, "/")
        fixed[h] = revs
        if h != head:
            changed = True

    if changed:
        print "%s: old property values detected; an upgrade is required." % NAME
        print
        print 'Please execute and commit these changes to upgrade:'
        print
        print 'svn propset "%s" "%s" "%s"' % \
            (opts["prop"], format_merge_props(fixed), branch_dir)
        sys.exit(1)

def analyze_revs(url, begin=1, end=None):
    """For the given url, analyze the revisions in the interval begin-end
    (which defaults to 1-HEAD), to find out which revisions are changes in
    the URL and which are changes elsewhere (so-called 'phantom' revisions).
    Return a tuple of two RevisionsList: (real_revs, phantom_revs).

    NOTE: To maximize speed, if "end" is not provided, the function is not
    able to find phantom revisions following the last real revision in the URL.
    """
    begin = str(begin)
    if end is None:
        end = "HEAD"
    else:
        end = str(end)

    out = launchsvn('log --quiet -r%s:%s "%s"' % (begin, end, url),
                    split_lines=False)
    revs = re.compile(r"^r(\d+)", re.M).findall(out)
    revs = RevisionList(",".join(revs))

    if end == "HEAD":
        # If end is not provided, we do not know which is the latest revision
        # in the repository. So return the phantom revision list only up to
        # the latest known revision.
        end = str(list(revs)[-1])

    phantom_revs = RevisionList("%s-%s" % (begin, end)) - revs
    return revs, phantom_revs

def analyze_head_revs(branch_dir, head_url):
    """For the given branch and head, extract the real and phantom
    head revisions."""
    # Extract the latest repository revision from the URL of the branch
    # directory (which is already cached at this point).
    head_rev = get_latestrev(target_to_url(branch_dir))

    # Calculate the base of analysis. If there is a "1-XX" interval in the
    # merged_revs, we do not need to check those.
    base = 1
    r = opts["merged_revs"].normalized()
    if r and r[0][0] == 1:
        base = r[0][1]

    return analyze_revs(head_url, base, head_rev)

def minimal_merge_intervals(revs, phantom_revs):
    """Produce the smallest number of intervals suitable for merging. revs
    is the RevisionList which we want to merge, and phantom_revs are phantom
    revisions which can be used to concatenate intervals, thus minimizing the
    number of operations."""
    revnums = revs.normalized()
    ret = []

    cur = revnums.pop()
    while revnums:
        next = revnums.pop()
        assert next[1] < cur[0]      # otherwise it is not ordered
        assert cur[0] - next[1] > 1  # otherwise it is not normalized
        for i in range(next[1]+1, cur[0]):
            if i not in phantom_revs:
                ret.append(cur)
                cur = next
                break
        else:
            cur = (next[0], cur[1])

    ret.append(cur)
    ret.reverse()
    return ret

def action_init(branch_dir, branch_props):
    """Initialize a branch for merges."""
    # Check branch directory is ready for being modified
    check_dir_clean(branch_dir)

    # Get initial revision list if not explicitly specified
    revs = opts["revision"] or "1-" + get_latestrev(opts["head_url"])
    revs = RevisionList(revs)

    report('marking "%s" as already containing revisions "%s" of "%s"' %
           (branch_dir, revs, opts["head_url"]))

    revs = str(revs)
    branch_props[opts["head_path"]] = revs

    # Set property
    set_merge_props(branch_dir, branch_props)

    # Write out commit message if desired
    if opts["commit_file"]:
        f = open(opts["commit_file"], "w")
        print >>f, 'Initialized merge tracking via "%s" with revisions "%s" from ' \
            % (NAME, revs)
        print >>f, '%s' % opts["head_url"]
        f.close()
        report('wrote commit message to "%s"' % opts["commit_file"])

def action_avail(branch_dir, branch_props):
    """Show commits available for merges."""
    head_revs, phantom_revs = analyze_head_revs(branch_dir, opts["head_url"])
    report('skipping phantom revisions: %s' % phantom_revs)

    blocked_revs = get_blocked_revs(branch_dir, opts["head_path"])
    avail_revs = head_revs - opts["merged_revs"] - blocked_revs

    # Compose the list of revisions to show
    revs = RevisionList("")
    if "avail" in opts["avail_showwhat"]:
        revs |= avail_revs
    if "blocked" in opts["avail_showwhat"]:
        revs |= blocked_revs

    # Limit to revisions specified by -r (if any)
    if opts["revision"]:
        revs = revs & RevisionList(opts["revision"])

    # Show them, either numerically, in log format, or as diffs
    if opts["avail_display"] == "revisions":
        report("available revisions to be merged are:")
        print revs
    elif opts["avail_display"] == "logs":
        for start,end in revs.normalized():
            svn_command('log --incremental -v -r %d:%d %s' % \
                        (start, end, opts["head_url"]))
    elif opts["avail_display"] == "diffs":
        for start,end in revs.normalized():
            print
            if start == end:
                print "%s: changes in revision %d follow" % (NAME, start)
            else:
                print "%s: changes in revisions %d-%d follow" % (NAME, start, end)
            print

            # Note: the starting revision number to 'svn diff' is
            # NOT inclusive so we have to subtract one from ${START}.
            svn_command('diff -r %d:%d %s' % \
                        (start-1, end, opts["head_url"]))
    else:
        assert 0, "unhandled avail display type: %s" % opts["avail_display"]

def action_merge(branch_dir, branch_props):
    """Do the actual merge."""
    # Check branch directory is ready for being modified
    check_dir_clean(branch_dir)

    head_revs, phantom_revs = analyze_head_revs(branch_dir, opts["head_url"])

    if opts["revision"]:
        revs = RevisionList(opts["revision"])
    else:
        revs = head_revs

    blocked_revs = get_blocked_revs(branch_dir, opts["head_path"])
    merged_revs = opts["merged_revs"]

    # Show what we're doing
    if opts["verbose"]:  # just to avoid useless calculations if we don't need reports
        if merged_revs & revs:
            report('"%s" already contains revisions %s' % (branch_dir, merged_revs & revs))
        if phantom_revs:
            report('memorizing phantom revision(s): %s' % phantom_revs)
        if blocked_revs & revs:
            report('skipping blocked revisions(s): %s' % (blocked_revs & revs))

    # Compute final merge list
    revs = revs - merged_revs - blocked_revs
    if not revs:
        report('no revisions to merge, exiting')
        return
    report('merging in revision(s) %s from "%s"' % (revs, opts["head_url"]))

    # Do the merge(s). Note: the starting revision number to 'svn merge'
    # is NOT inclusive so we have to subtract one from start.
    # We try to keep the number of merge operations as low as possible,
    # because it is faster and reduces the number of conflicts.
    for start,end in minimal_merge_intervals(revs, phantom_revs):
        svn_command('merge -r %d:%d %s %s' % \
                    (start-1, end, opts["head_url"], branch_dir))

    # Write out commit message if desired
    if opts["commit_file"]:
        f = open(opts["commit_file"], "w")
        print >>f, 'Merged revisions %s via %s from ' % (revs, NAME)
        print >>f, '%s' % opts["head_url"]
        if opts["commit_verbose"]:
            print >>f
            print >>f, construct_merged_log_message(opts["head_url"], revs),

        f.close()
        report('wrote commit message to "%s"' % opts["commit_file"])

    # Update list of merged revisions
    merged_revs = merged_revs | revs | phantom_revs
    branch_props[opts["head_path"]] = str(merged_revs)
    set_merge_props(branch_dir, branch_props)

def action_block(branch_dir, branch_props):
    """Block revisions."""
    # Check branch directory is ready for being modified
    check_dir_clean(branch_dir)

    head_revs, phantom_revs = analyze_head_revs(branch_dir, opts["head_url"])
    revs_to_block = head_revs - opts["merged_revs"]

    # Limit to revisions specified by -r (if any)
    if opts["revision"]:
        revs_to_block = RevisionList(opts["revision"]) & revs_to_block

    if not revs_to_block:
        error('no available revisions to block')

    # Change blocked information
    blocked_revs = get_blocked_revs(branch_dir, opts["head_path"])
    blocked_revs = blocked_revs | revs_to_block
    set_blocked_revs(branch_dir, opts["head_path"], blocked_revs)

    # Write out commit message if desired
    if opts["commit_file"]:
        f = open(opts["commit_file"], "w")
        print >>f, 'Blocked revisions %s via %s' % (revs_to_block, NAME)
        if opts["commit_verbose"]:
            print >>f
            print >>f, construct_merged_log_message(opts["head_url"],
                                                    revs_to_block),

        f.close()
        report('wrote commit message to "%s"' % opts["commit_file"])

def action_unblock(branch_dir, branch_props):
    """Unblock revisions."""
    # Check branch directory is ready for being modified
    check_dir_clean(branch_dir)

    blocked_revs = get_blocked_revs(branch_dir, opts["head_path"])
    revs_to_unblock = blocked_revs

    # Limit to revisions specified by -r (if any)
    if opts["revision"]:
        revs_to_unblock = revs_to_unblock & RevisionList(opts["revision"])

    if not revs_to_unblock:
        error('no available revisions to unblock')

    # Change blocked information
    blocked_revs = blocked_revs - revs_to_unblock
    set_blocked_revs(branch_dir, opts["head_path"], blocked_revs)

    # Write out commit message if desired
    if opts["commit_file"]:
        f = open(opts["commit_file"], "w")
        print >>f, 'Unblocked revisions %s via %s' % (revs_to_unblock, NAME)
        if opts["commit_verbose"]:
            print >>f
            print >>f, construct_merged_log_message(opts["head_url"],
                                                    revs_to_unblock),
        f.close()
        report('wrote commit message to "%s"' % opts["commit_file"])


###############################################################################
# Command line parsing -- options and commands management
###############################################################################

class OptBase:
    def __init__(self, *args, **kwargs):
        self.help = kwargs.pop("help")
        self.lflags = []
        self.sflags = []
        for a in args:
            if a.startswith("--"):   self.lflags.append(a)
            elif a.startswith("-"):  self.sflags.append(a)
            else:
                raise TypeError, "invalid flag name: %s" % a
        if "dest" in kwargs:
            self.dest = kwargs.pop("dest")
        else:
            if not self.lflags:
                raise TypeError, "cannot deduce dest name without long options"
            self.dest = self.lflags[0][2:].replace("-", "_")
        if kwargs:
            raise TypeError, "invalid keyword arguments: %r" % kwargs.keys()
    def repr_flags(self):
        f = self.sflags + self.lflags
        r = f[0]
        for fl in f[1:]:
            r += " [%s]" % fl
        return r

class Option(OptBase):
    def __init__(self, *args, **kwargs):
        self.default = kwargs.pop("default", 0)
        self.value = kwargs.pop("value", None)
        OptBase.__init__(self, *args, **kwargs)
    def apply(self, state, value):
        assert value == ""
        if self.value is not None:
            state[self.dest] = self.value
        else:
            state[self.dest] += 1

class OptionArg(OptBase):
    def __init__(self, *args, **kwargs):
        self.default = kwargs.pop("default")
        self.metavar = kwargs.pop("metavar", None)
        OptBase.__init__(self, *args, **kwargs)

        if self.metavar is None:
            if self.dest is not None:
                self.metavar = self.dest.upper()
            else:
                self.metavar = "arg"
        if self.default:
            self.help += " (default: %s)" % self.default
    def apply(self, state, value):
        assert value is not None
        state[self.dest] = value
    def repr_flags(self):
        r = OptBase.repr_flags(self)
        return r + " " + self.metavar

class CommandOpts:
    class Cmd:
        def __init__(self, *args):
            self.name, self.func, self.usage, self.help, self.opts = args
        def short_help(self):
            return self.help.split(".")[0]
        def __str__(self):
            return self.name
        def __call__(self, *args, **kwargs):
            return self.func(*args, **kwargs)

    def __init__(self, global_opts, common_opts, command_table,
                 version=None):
        self.progname = NAME
        self.version = version.replace("%prog", self.progname)
        self.cwidth = console_width() - 2
        self.ctable = command_table
        self.gopts = global_opts
        self.copts = common_opts
        self._add_builtins()
        for k in self.ctable:
            cmd = self.Cmd(k, *self.ctable[k])
            opts = []
            for o in cmd.opts:
                if isinstance(o, types.StringTypes):
                    o = self._find_common(o)
                opts.append(o)
            cmd.opts = opts
            self.ctable[k] = cmd

    def _add_builtins(self):
        self.gopts.append(
            Option("-h", "--help", help="show help for this command and exit"))
        if self.version is not None:
            self.gopts.append(
                Option("-V", "--version", help="show version info and exit"))
        self.ctable["help"] = (self._cmd_help,
            "help [COMMAND]",
            "Display help for a specific command. If COMMAND is omitted, "
            "display brief command description.",
            [])

    def _cmd_help(self, cmd=None, *args):
        if args:
            self.error("wrong number of arguments", "help")
        if cmd is not None:
            cmd = self._command(cmd)
            self.print_command_help(cmd)
        else:
            self.print_command_list()

    def _paragraph(self, text, width=78):
        chunks = re.split("\s+", text.strip())
        chunks.reverse()
        lines = []
        while chunks:
            L = chunks.pop()
            while chunks and len(L) + len(chunks[-1]) + 1 <= width:
                L += " " + chunks.pop()
            lines.append(L)
        return lines

    def _paragraphs(self, text, *args, **kwargs):
        pars = text.split("\n\n")
        lines = self._paragraph(pars[0], *args, **kwargs)
        for p in pars[1:]:
            lines.append("")
            lines.extend(self._paragraph(p, *args, **kwargs))
        return lines

    def _print_wrapped(self, text, indent=0):
        text = self._paragraphs(text, self.cwidth - indent)
        print text.pop(0)
        for t in text:
            print " " * indent + t

    def _find_common(self, fl):
        for o in self.copts:
            if fl in o.lflags+o.sflags:
                return o
        assert 0, fl

    def _fancy_getopt(self, args, opts, state=None):
        back = {}
        sfl = ""
        lfl = []
        if state is None:
            state= {}
        for o in opts:
            sapp = lapp = ""
            if o.dest not in state:
                state[o.dest] = o.default
            if isinstance(o, OptionArg):
                sapp, lapp = ":", "="
            for s in o.sflags:
                if back.has_key(s):
                    raise RuntimeError, "option conflict: %s" % s
                back[s] = o
                sfl += s[1:] + sapp
            for l in o.lflags:
                if back.has_key(l):
                    raise RuntimeError, "option conflict: %s" % l
                back[l] = o
                lfl.append(l[2:] + lapp)

        lopts,args = getopt.getopt(args, sfl, lfl)
        for o,v in lopts:
            back[o].apply(state, v)
        return state, args

    def _command(self, cmd):
        if cmd not in self.ctable:
            self.error("unknown command: '%s'" % cmd)
        return self.ctable[cmd]

    def parse(self, args):
        if not args:
            self.print_small_help()
            sys.exit(0)

        cmd = None
        try:
            opts, args = self._fancy_getopt(args, self.gopts)
            if args:
                cmd = self._command(args.pop(0))
                opts, args = self._fancy_getopt(args, self.gopts + cmd.opts, opts)
        except getopt.GetoptError, e:
            self.error(e, cmd)

        # Handle builtins
        if self.version is not None and opts["version"]:
            self.print_version()
            sys.exit(0)
        if opts["help"]: # --help
            if cmd is None:
                cmd = self.ctable["help"]
            else:
                self.print_command_help(cmd)
                sys.exit(0)
        if cmd is None:
            self.error("command argument required")
        if str(cmd) == "help":
            cmd(*args)
            sys.exit(0)
        return cmd, args, opts

    def error(self, s, cmd=None):
        print >>sys.stderr, "%s: %s" % (self.progname, s)
        if cmd is not None:
            self.print_command_help(cmd)
        else:
            self.print_small_help()
        sys.exit(1)
    def print_small_help(self):
        print "Type '%s help' for usage" % self.progname
    def print_usage_line(self):
        print "usage: %s <subcommand> [options...] [args...]\n" % self.progname
    def print_command_list(self):
        print 'Available commands (use "%s help COMMAND" for more details):\n' % self.progname
        cmds = self.ctable.keys()
        cmds.sort()
        indent = max(map(len, cmds))
        for c in cmds:
            h = self.ctable[c].short_help()
            print "  %-*s   " % (indent, c),
            self._print_wrapped(h, indent+6)
    def print_command_help(self, cmd):
        cmd = self.ctable[str(cmd)]
        print 'usage: %s %s\n' % (self.progname, cmd.usage)
        self._print_wrapped(cmd.help)
        def print_opts(opts):
            if not opts: return
            flags = [o.repr_flags() for o in opts]
            indent = max(map(len, flags))
            for f,o in zip(flags, opts):
                print "  %-*s :" % (indent, f),
                self._print_wrapped(o.help, indent+5)
        print '\nCommand options:'
        print_opts(cmd.opts)
        print '\nGlobal options:'
        print_opts(self.gopts)

    def print_version(self):
        print self.version


###############################################################################
# Options and Commands description
###############################################################################

global_opts = [
    Option("-v", "--verbose",
           help="verbose mode: output more information about progress"),
    Option("-s", "--show-changes",
           help="show subversion commands that make changes"),
    Option("-n", "--dry-run",
           help="don't actually change anything, just pretend; implies --show-changes"),
    Option("-F", "--force",
           help="force operation even if the working copy is not clean, or "
                "there are pending updates"),
]

common_opts = [
    OptionArg("-r", "--revision", metavar="REVLIST", default="",
              help="specify a revision list, consisting of revision numbers "
                   'and ranges separated by commas, e.g., "534,537-539,540"'),
    OptionArg("-f", "--commit-file", metavar="FILE", default="svnmerge-commit-message.txt",
              help="set the name of the file where the suggested log message "
                   "is written to"),
    OptionArg("-S", "--head", "--source", default=None,
              help="specify the head for this branch. It can be either a path "
                   "or an URL. Needed only to disambiguate in case of multiple "
                   "merge tracking (merging from multiple heads)"),
]

command_table = {
    "init": (action_init,
    "init [OPTION...] [HEAD]",
    """Initialize merge tracking from HEAD on the current working
    directory.

    If HEAD is specified, all the revisions in HEAD are marked as already
    merged; if this is not correct, you can use --revision to specify the
    exact list of already-merged revisions.

    If HEAD is omitted, then it is computed from the "svn cp" history of the
    current working directory (searching back for the branch point); in this
    case, %s assumes that no revision has been integrated yet since
    the branch point (unless you teach it with --revision).""" % NAME,
    [
        "-r", "-f", # import common opts
    ]),

    "avail": (action_avail,
    "avail [OPTION...] [PATH]",
    """Show unmerged revisions available for PATH as a revision list.
    If --revision is given, the revisions shown will be limited to those
    also specified in the option.""",
    [
        Option("-l", "--log",
               dest="avail_display", value="logs", default="revisions",
               help="show corresponding log history instead of revision list"),
        Option("-d", "--diff",
               dest="avail_display", value="diffs",
               help="show corresponding diff instead of revision list"),
        Option("-B", "--blocked",
               dest="avail_showwhat", value=["blocked"], default=["avail"],
               help='show the blocked revision list (see "%s block")' % NAME),
        Option("-A", "--all",
               dest="avail_showwhat", value=["blocked", "avail"],
               help="show both available and blocked revisions (aka ignore "
                    "blocked revisions)"),
        "-r", "-S", # import common opts
    ]),

    "merge": (action_merge,
    "merge [OPTION...] [PATH]",
    """Merge in revisions into PATH from its head. If --revision is omitted,
    all the available revisions will be merged. In any case, already merged-in
    revisions will NOT be merged again.""",
    [
        "-r", "-S", "-f", # import common opts
    ]),

    "block": (action_block,
    "block [OPTION...] [PATH]",
    """Block revisions within PATH so that they disappear from the available
    list. This is useful to hide revisions which will not be integrated.
    If --revision is omitted, it defaults to all the available revisions.""",
    [
        "-r", "-S", "-f", # import common opts
    ]),

    "unblock": (action_unblock,
    "unblock [OPTION...] [PATH]",
    """Revert the effect of "%s block". If --revision is omitted, all the
    blocked revisions are unblocked""" % NAME,
    [
        "-r", "-S", "-f", # import common opts
    ]),
}


def main(args):
    global opts

    optsparser = CommandOpts(global_opts, common_opts, command_table,
                             version="%%prog r%s\n  modified: %s\n\n"
                                     "Copyright (C) 2004,2005 Awarix Inc.\n"
                                     "Copyright (C) 2005, Giovanni Bajo" % (SRCREV, SRCDATE))

    cmd, args, state = optsparser.parse(args)
    opts.update(state)

    head = opts.get("head", None)
    branch_dir = "."

    if str(cmd) == "init":
        if len(args) == 1:
            head = args[0]
        elif len(args) > 1:
            optsparser.error("wrong number of parameters", cmd)
    elif str(cmd) in ["avail", "merge", "block", "unblock"]:
        if len(args) == 1:
            branch_dir = args[0]
        elif len(args) > 1:
            optsparser.error("wrong number of parameters", cmd)
    else:
        assert 0, "command not handled: %s" % cmd

    # Validate branch_dir
    if not is_wc(branch_dir):
        error('"%s" is not a subversion working directory' % branch_dir)

    # Extract the integration info for the branch_dir
    branch_props = get_merge_props(branch_dir)
    check_old_prop_version(branch_dir, branch_props)

    # Calculate head_url and head_path
    report("calculate head path for the branch")
    if not head:
        if str(cmd) == "init":
            cf_head, cf_rev = get_copyfrom(branch_dir)
            if not cf_head:
                error('no copyfrom info available. '
                      'Explicit head argument (-S/--head) required.')
            opts["head_path"] = cf_head
            if not opts["revision"]:
                opts["revision"] = "1-" + cf_rev
        else:
            opts["head_path"] = get_default_head(branch_dir, branch_props)

        assert opts["head_path"][0] == '/'
        opts["head_url"] = get_repo_root(branch_dir) + opts["head_path"]
    else:
        # The source was given as a command line argument and is stored in
        # HEAD.  Ensure that the specified source does not end in a /,
        # otherwise it's easy to have the same source path listed more
        # than once in the integrated version properties, with and without
        # trailing /'s.
        head = rstrip(head, "/")
        if not is_wc(head) and not is_url(head):
            error('"%s" is not a valid URL or working directory' % head)
        opts["head_url"] = target_to_url(head)
        opts["head_path"] = url_to_rlpath(opts["head_url"])

    # Sanity check head_url
    assert is_url(opts["head_url"])
    # SVN does not support non-normalized URL (and we should not have created them)
    assert opts["head_url"].find("/..") < 0

    report('head is "%s"' % opts["head_url"])

    # Get previously merged revisions (except when command is init)
    if str(cmd) != "init":
        if not branch_props.has_key(opts["head_path"]):
            error('no integration info available for repository path "%s"' % opts["head_path"])

        revs = branch_props[opts["head_path"]]
        opts["merged_revs"] = RevisionList(revs)

    # Perform the action
    cmd(branch_dir, branch_props)


if __name__ == "__main__":
    try:
        main(sys.argv[1:])
    except LaunchError, (ret, cmd, out):
        print "%s: command execution failed (exit code: %d)" % (NAME, ret)
        print cmd
        print "".join(out)
        sys.exit(1)
    except KeyboardInterrupt:
        # Avoid traceback on CTRL+C
        print "aborted by user"
        sys.exit(1)

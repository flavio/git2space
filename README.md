
Simple (and highly experimental) project to smooth the development of the python
parts of Spacewalk (and SUSE Manager).

## The problem

You just changed a python file and want to have the new version on one of your
Spacewalk machines.

The usual approach consists in:
  * rebuilding the rpm containing the file you just changed
  * copying the rpm to your system
  * installing the rpm

## The workaround

git2space connects to a running spacewalk instance, looks for all the SUSE Manager
package installed and inspects the contents of each package. A hash map is built
using these informations and stored locally. The hash map is specific to a host
and is cached to make git2space execution faster.

You can use git2space to push a modified file to a machine known by the tool.
git2space will look at the filename and guess its final destination on the server
by looking at the hash map. If the file is not found (you could be pushing a totally
new file) git2space will try to guess the final location by looking at the siblings.

## Disclaimer

git2space is just a quick hack I wrote sometimes ago while working on SUSE Manager.
It worked pretty fine for my needs but I never had the time to polish it or to
write a good documentation.

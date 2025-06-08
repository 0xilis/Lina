# Lina

There are not likely to be any security issues in Lina. It is an app in Swift and generally does not do dangerous dynamic memory management, and filesystem race conditions cannot really be done on iOS or iPadOS.

While there is a greater chance of there being problems in its framework powering it, NeoAppleArchive, issues relating to this should be reported to the GitHub Security Advisory ["Report a Vulnerability"](https://github.com/0xilis/libNeoAppleArchive/security/advisories/new) tab on the libNeoAppleArchive page and not the page for Lina, unless it is some way Lina is using it that makes it specifically affect Lina / a Lina issue.

Nonetheless, just in case, I am opening private vulnerability reporting in case you do happen to find anything. If you somehow do, I'll be seriously impressed! I'll make sure to credit you for your findings. Please report issues to the GitHub Security Advisory ["Report a Vulnerability"](https://github.com/0xilis/Lina/security/advisories/new) tab for Lina. Lina is a completely free project so be aware I will not be able to give any bounties, apologies.

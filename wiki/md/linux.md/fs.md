##### Filesystems
------------------

1. ###### XFS

- use B+ tree: see https://en.wikipedia.org/wiki/B%2B_tree

- it breaks space in contigious groups (Allocation groups);

- it can reserve I/O bandwidth: soft and hard way depending on the underlying block device

- it can be freezed to make snapshots

- it is journaling FS;

- native backup (online): use xfsdump and xfsrestore. It provides online backup no need to unmount a partition.

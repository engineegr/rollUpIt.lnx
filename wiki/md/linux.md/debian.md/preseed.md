#### Preseed
--------------

1. ##### About auto partition:

The algorithm is actually fairly straightforward. First it works out a **percentage weight** for each partition. It does this by subtracting the minimum value from the priority. *If the priority is less than the minimum the minimum is used instead*, which results in a zero value for this calculation. The values for all partitions are then added together and a percentage calculated for each one. So in the above example we have percentages of 49%, 2% and 49% for each partition in turn (yes, it’s no coincidence that the priorities were chosen to make percentage calculations easy).

Next, with a percentage weight for each partition it moves on to looking at the free space. **It starts by giving each partition its minimum value** (there must be enough disk space for that, otherwise the process fails) and then works out what space is left over. **Each partition is then assigned a percentage of that left over space based on the figure from the previous step. **That’s it – it’s as simple as that! Assuming none have gone over their maximum value we’re done.

**If a partition does get assigned a value over its maximum then the maximum is taken as the new size instead and the priority for that partition becomes zero. Another pass around the loop is done, ignoring that partition completely** for the percentage calculations, and the remaining free space assigned to the other partitions. This process repeats until there is no more space, or until all have hit their maximum values.

As a side note, when all partitions hit their maximum values the remaining space gets assigned to the last partition when the partitions are created. Personally I’d prefer it was left free on the disk, but it’s not configurable.

2. ##### How to check a preseed file?
`debconf-set-selections -c preseed.cfg`

> [Links]
> 1. [Understanding partman-auto/expert_recipe](https://www.bishnet.net/tim/blog/2015/01/29/understanding-partman-autoexpert_recipe/)

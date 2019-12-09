#### Grokking algorithms 
-----------------------

1. ##### Recursion

- We must use return statements in every call of the function to get a ultimate result unless we will receive an implicit return value of the first function call (in this case, **None**):

Example 001. Binary search
```
def binarySearch_SORT_GALG(sort_array, wanted, left, right):
  mi = int((left + right)/2)
  print(f"Debug binarySearch_SORT_GALG mi {mi} left {left} right {right}\n")
  if sort_array[mi] > wanted:
      if mi == 0:
          print(f"Debug binarySearch_SORT_GALG {wanted} < minimal value in the array {sort_array[0]} \n")
          return None
      else:
          return binarySearch_SORT_GALG(sort_array, wanted, left, mi)
  elif sort_array[mi] < wanted:
      length = len(sort_array)
      if (length - mi) == 1:
          print(f"Debug binarySearch_SORT_GALG {wanted} > maximal value in the array {sort_array[length - 1]} \n")
          return None
      else:
          return binarySearch_SORT_GALG(sort_array, wanted, mi, right)
  elif sort_array[mi] == wanted:
      return mi
```

**Good explanation from** [here](https://stackoverflow.com/questions/11356168/return-in-recursive-function)

[!Links]
> 1. [Grokking algorithms of Aditya Bhargava](https://www.amazon.com/Grokking-Algorithms-illustrated-programmers-curious/dp/1617292230/ref=nodl_)

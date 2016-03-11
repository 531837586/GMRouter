# GMRouter
A URL Router who parse url use regex express for iOS. Inspired by [HHRouter](https://github.com/Huohua/HHRouter)

# Usage

## Warm Up

Map URL patterns to a block.

```
GMRouter *router = [GMRouter shared];
GMRouterBlock block = ^(NSDictionary *params) {
    NSLog(@"%@", params[@"uid"]);
    NSLog(@"%@", params[@"pid"]);
};


[router map:@"/gemini/[uid]/[pid]" toBlock:block];

```

## What we get next

Get the block and parameters when request a url

```
GMRouterBlock newBlock = [router matchBlock:@"/gemini/123/23423?hello=world"];
newBlock(nil);
```

We will get the params in block.



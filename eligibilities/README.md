# Script to extract smesher eligibilities from go-spacemesh node.

Export your eligibilities from one or more nodes to a json file with the following properties:
- epoch number
- eligible layers
- eligible layer count
- smesher ids with eligible layers

Requirements:
- update NODES array with details of your proving or 1:n node
- jq package, and grpcurl binary (in bin path e.g. /usr/local/bin/)
- grpc-private-listener api available to be queried
- Linux bash shell (but should work in other OS where bash is available)

Sample output:
```json
{
  "epoch": 28,
  "layers": [
    114977,
    115269,
    116251,
    116544,
    117011
  ],
  "layer_count": 5,
  "smeshers": [
    "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
    "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=",
    "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD=",
    "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE="
  ]
}

```
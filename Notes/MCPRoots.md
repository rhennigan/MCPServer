# MCP Roots

## Goals

We need to add support for MCP roots. When a client sets roots, it will typically be for a project directory (e.g. Claude Code). We should use this information to properly configure our tools to operate in this directory.

## Implementation Notes

### Sending requests

We can’t assume that the next incoming message after making a request to the client will be the response to our request, since there may be multiple incoming messages already buffered. To make this robust, we should implement a system for sending requests to the client and registering a handler for when the response eventually arrives. Here is a rough draft of how something like that could work:

Create a global registry of client requests:

```wl
$mcpClientRequests = <| |>;
```

When we make a request to the client, use a UUID for the jsonrpc ID instead of an integer. We do this to avoid ID collisions with messages coming from the client, which typically start at 0 and increment with each new message.

```wl
uuid = CreateUUID[ ];
	
$mcpClientRequests[ uuid ] = <|
    "id"       -> uuid, 
    "request" -> <| ... |>, (* the request message we sent to the client *)
    "handler" -> handlerFunction
|>;
```

We then write the request to standard output and proceed to the normal loop of waiting for messages.

### Receiving responses

When we receive a message from the client, we can determine if it’s a response to one of our requests by checking the ID:

```wl
KeyExistsQ[ $mcpClientRequests, message[ "id" ] ]
```

If it is a response, we process it using the appropriate handler:

```wl
handler = $mcpClientRequests[ id, "handler" ];
request = $mcpClientRequests[ id, "request" ];
handler[ request, message ];
```

We then remove it from ``$mcpClientRequests`` :

```wl
KeyDropFrom[ $mcpClientRequests, id ]
```

### Setting roots

MCP allows for multiple roots, but for our purposes, it only makes sense to use one. If a response comes back with more than one root, we should simply take the first one that points to a valid directory and ignore the rest as a heuristic.

We should do the following when setting a root directory:

* Set directory using ``SetDirectory[root]``

* Also ensure the evaluator kernel is set via ``useEvaluatorKernel[SetDirectory[root]]``

* Ensure that tools using ``RunProcess`` start in the correct directory with ``RunProcess[args, ProcessDirectory -> root]`` so that relative paths resolve correctly

### Handling root changes

A client that declares the ``"listChanged"`` capability for roots may change roots during a session using a notification:

```
{
  "jsonrpc": "2.0",
  "method": "notifications/roots/list_changed"
}
```

We should handle this notification by requesting new roots when we receive it.

## Additional Context

See [MCP documentation for roots](https://modelcontextprotocol.io/specification/2025-11-25/client/roots.md) for additional details.
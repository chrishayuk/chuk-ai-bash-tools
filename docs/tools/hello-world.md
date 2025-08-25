# hello.world

Test tool for verifying installation and demonstrating the JSON contract.

## Installation

```bash
# Install individually
./install.sh hello.world

# Install with hello group
./install.sh --group hello
```

## Usage

```bash
# Basic usage
echo '{"name":"World"}' | hello.world | jq

# With all options
echo '{"name":"AI","greeting":"Hey","excited":true,"repeat":3}' | hello.world | jq
```

## Input Schema

```json
{
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "description": "Name to greet",
      "default": "World"
    },
    "greeting": {
      "type": "string", 
      "description": "Greeting word to use",
      "default": "Hello",
      "examples": ["Hello", "Hi", "Hey", "Greetings"]
    },
    "excited": {
      "type": "boolean",
      "description": "Add excitement with exclamation marks",
      "default": false
    },
    "repeat": {
      "type": "integer",
      "description": "Number of times to repeat greeting",
      "minimum": 1,
      "maximum": 10,
      "default": 1
    }
  }
}
```

## Output Schema

```json
{
  "type": "object",
  "properties": {
    "ok": {
      "type": "boolean",
      "description": "Success status"
    },
    "message": {
      "type": "string",
      "description": "The greeting message"
    },
    "messages": {
      "type": "array",
      "description": "Array of messages (when repeat > 1)"
    },
    "timestamp": {
      "type": "string",
      "format": "date-time",
      "description": "ISO 8601 timestamp"
    },
    "greeted": {
      "type": "string",
      "description": "The name that was greeted"
    },
    "count": {
      "type": "integer",
      "description": "Number of repetitions (when repeat > 1)"
    }
  }
}
```

## Examples

### Basic Greeting
```bash
$ echo '{"name":"World"}' | hello.world | jq
{
  "ok": true,
  "message": "Hello, World.",
  "timestamp": "2024-01-20T10:30:00Z",
  "greeted": "World"
}
```

### Excited Greeting
```bash
$ echo '{"name":"Claude","excited":true}' | hello.world | jq
{
  "ok": true,
  "message": "Hello, Claude!",
  "timestamp": "2024-01-20T10:30:00Z",
  "greeted": "Claude"
}
```

### Custom Greeting
```bash
$ echo '{"name":"Friend","greeting":"Greetings"}' | hello.world | jq
{
  "ok": true,
  "message": "Greetings, Friend.",
  "timestamp": "2024-01-20T10:30:00Z",
  "greeted": "Friend"
}
```

### Repea
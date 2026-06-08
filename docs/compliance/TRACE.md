# Traceability Matrix

Auto-generated.  Run `make compliance` to verify.

Source: HLR tags in `.ads` files + LLR mapping in `LLR.md`.

## HLR → Source Files

| HLR | Source |
|-----|--------|
{% for result in results -%}
| {{ result.hlr }} | `{{ result.file }}` |
{% endfor %}

"""

Contains the single source of truth for modules and their dependencies.

Entry format:
"<group>/<module>": [<group1>, <group2>, ...]

"""

AMPLE_HW_DEPS = {
    # Activations
    "lib/arithmetic/fp32_silu": [],
}
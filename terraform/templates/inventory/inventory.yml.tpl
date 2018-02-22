---
all:
  children:
    pristine:
      hosts:
        ${host}
    managed:
      hosts:
        dev:
          ansible_host: ${host}

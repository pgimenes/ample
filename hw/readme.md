### Environment Variables

| Variable        | Description                                                                                                                                                          | Default |
|-----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|
| DRAM_CONTROLLER | Instantiate DRAM Controller in Top RTL                                                                                                                               | 0       |
| DRAM_MODEL      | Instantiate DRAM Model in Top TB. If set to 1, DRAM controller outputs from RTL will be used to drive model. If set to 0, AXI outputs from RTL will drive RAM model. | 0       |
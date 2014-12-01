## RNA-Seq analysis with READemption - Setup and usage in the EGI Federated Cloud

This is a collection of scripts used during the 
[EGI](https://www.egi.eu) webinar "RNA-Seq analysis with READemption - Setup
and usage in the EGI Federated Cloud" given at November, 27th, 2014 by
Konrad Förstner.

* `create_vm.sh`: Creates the virtual machine
* `setup_system_on_egi_vm.sh`: Installs required software on the virtual machine
* `get_rna_seq_data_from_geo.sh`: Retrieves and pre-processes the RNA-Seq data 
* `run_reademption_analysis.sh`: Performs the actual analysis using
  [READemption](http://pythonhosted.org/READemption/)

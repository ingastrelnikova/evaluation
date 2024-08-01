## Reproducing the evaluation process

To reproduce the evaluation process, these steps should be followed:

### Preparation

1. **Create virtual machine**

Execute scripts to create the virtual machine.

   ```bash
   cd scripts
   chmod +x 1_create_vm.sh
   ./1_create_vm.sh
  ```
2. **Set up the load generator and the database**

After the virtual machines are set up, the load generator and the database have to be started in Docker.
  
   ```bash
   chmod +x 2_run_experiment.sh
   ./2_run_experiment.sh
  ```

4. **Download the results**

The results were downloaded manually, by connecting to the virtual machine with ssh and the files were first downloaded from docker and then to the local machine.

The following commands were used:

  ```bash
  docker cp $(docker ps -aqf "name=loadgen"):app/write_log.csv /home/$USER/app
  ```

5. **Analyze the results**

The results from all 3 experiments were put in one folder and the jupyter notebook "analyze_results.ipynb" was executed.






   

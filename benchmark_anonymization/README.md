## Reproducing the evaluation process

To reproduce the evaluation process, these steps should be followed:

### Preparation

1. **Create virtual machines**

Execute scripts to create the virtual machines.

   ```bash
   cd scripts
   chmod +x 1_create_vms.sh
   ./1_create_vms.sh
  ```
2. **Set up the anonymization service and the database**

After the virtual machines are set up, the anonymization service and the database with other necessary components have to be started in Docker.
  
   ```bash
   chmod +x 2_run_anon.sh
   chmod +x 2_run_db.sh
   ./2_run_anon.sh
   ./2_run_db.sh
  ```

3. **Set up the anonymization service and the database**

The sending of anonymization requests has to be started.

   ```bash
   cd scripts
   chmod +x 3_send_requests.sh
   ./3_send_requests.sh
   ```
4. **Download the results**

The results were downloaded manually, by connecting to the virtual machine with ssh and the files were first downloaded from docker and then to the local machine.

The following commands were used:

  ```bash
  docker cp $(docker ps -aqf "name=anonymization-service"):app/anonymization_log.csv /home/$USER/app
  ```
The the same experiments of sending requests were repeated 3 times and 3 datasets with the results were then analyzed.

5. **Analyze the results**

The results from all 3 experiments were put in one folder and the jupyter notebook "analyze_results.ipynb" was executed.






   

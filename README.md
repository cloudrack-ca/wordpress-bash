# How to
- To simply run this just copy and paste this into a fresh 18.04 Ubuntu or above server.
# Confirmed Working On
- [`Dell r210 1U Racked Chasised Server`](https://i.dell.com/sites/csdocuments/Shared-Content_data-Sheets_Documents/en/R210-SpecSheet.pdf) | **( Ubuntu 18.04 )**
- [`Dell r210 1U Racked Chasised Server`](https://i.dell.com/sites/csdocuments/Shared-Content_data-Sheets_Documents/en/R210-SpecSheet.pdf) | **( Ubuntu 22.04 )**
 
# Consider Donating Towards My Projects
 - Like my work? Please donate @ [HERE](https://donatebot.io/checkout/1154471425663574039?buyer=142025929454125056)
   
  **( Must Be Run On A Clean Server - Base is Ubuntu18.04 And above )**
###  If you need help with this then this please join my discord [**HERE**](https://join.cloudrack.ca)

```shell
sudo apt update && sudo apt install wget -y && wget -L https://raw.githubusercontent.com/cloudrack-ca/wp-bash/main/wp-bash.sh && clear && bash wp-bash.sh
```

# Installation logs
- These can be found simply by using the below command in another window well the installation performs.
```shell
cd && tail -f install.log
```
### note 
  - if you perform the above command **AFTER** the install you will need to press crtl+c to cancel and exit the command - if the install has completed already please use the command below to show the logs of the installation
  - You will need to press crtl+c in the window the logs are open after the installation is done to exit the logs BUT you may also close your terminal as well this typically works but is not ideal as it can create zombie process and enough zombies can clutter your system just like the real world.
  
# To Display after install
```shell
cd && cat -f install.log
```
  

---
# Credits
🎩 hats are off to Github & Their Lovely Copilot @ https://github.com/features/copilot made without writing one line of code myself, and has already helped me learn from docker-compose.yml to using actions on github and so much more!!! 💖 to the whole [`Github team!`](https://github.com/team)

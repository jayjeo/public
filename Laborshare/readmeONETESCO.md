# General Instructions for Entire Paper.
  * [https://github.com/jayjeo/public/blob/main/Laborshare/readme.md](https://github.com/jayjeo/public/blob/main/Laborshare/readme.md)

# Instructions for the comparison between ONET and ESCO by using embedding feature. 

### VERSION CONTROLS:
Developed under Python 3.10.9

For Windows, open Command Prompt (cmd) or PowerShell, and type these lines. 
```
pip install openai==1.30.1
pip install numpy==1.26.4
pip install pandas==2.2.2
pip install lxml==5.2.1
pip install sentence-transformers==2.7.0
pip install scikit-learn==1.4.2
pip install cosine_similarity==0.1.2
pip install pairwise==0.1
pip install metrics==0.3.3
pip install Optional==0.0.1
pip install torch==2.3.0
pip install mp==0.5.0
pip install Pool==0.1.2
pip install cpu_count==1.0.0
pip install typing==3.7.4.3
pip install matplotlib==3.9.0
pip install bs4==0.0.2
pip install openpyxl==3.1.3
pip install psutil==5.9.8
pip install pyreadstat==1.2.7
```

### STEPS:
  * Sequentially follow the steps explained in the "ESCO vs ONET comparison" section in master.do.

### NOTES 1:
  * Import_ONET_Tasks.py may not work in the future.
    * ESCO provides occupation and task information in a CSV file. Inside this CSV, they only provide HTML links to the ESCO webpage (they do not provide the actual code numbers or task descriptions). To avoid the tedious manual work of copying and pasting by visiting each link, this Python code automatically captures the necessary information from the webpage HTML and stores it in a CSV file.
    * If the HTML structure of the webpage changes, you may need to adjust the parsing logic accordingly. Therefore, this Python code may not work in the future if there is a webpage update from ESCO.
  * In case the HTML structure has changed and this code does not work, and if you do not want to modify the Python code accordingly, just download the final result of this code from the link below. The final result is stored in a folder named 'ESCO HTML Parsing', so you can skip running this Python code.
    * https://www.dropbox.com/scl/fo/jmbbjgw6hda3bn30abhv1/AGQ73nI4rysYXWC_rN2fjXE?rlkey=y5vnz4k3xl08j8oyomxypv2h4&st=qtfojwl7&dl=0

### NOTES 2:
  * These codes use the embedding feature recently developed by Microsoft.
  * Utilizing the OpenAI embedding method does not require GPU computing power, as it employs the server API from OpenAI, which is closed-source. In contrast, the Microsoft method uses an open-source embedding feature that operates directly on your computer without relying on Microsoft's servers. This independence from Microsoft's servers is beneficial, but the downside is that computing speed crucially depends on your own computing power. This is why this code requires a powerful GPU.  
  * I used a server with 100 CPUs and a special GPU as described below. I cannot guarantee that a private local computer with one CPU can handle this code, but it may work well.
    *  AMD EPYC 7742 vCPUs (100 CPUs), A100 SXM4 80 GB (1 GPU), 340 GB RAM
    *  I recommend using a server provided by TensorDock as it is relatively cheap, very reliable, and the staff feedback is fast and good.
  * If a private local computer with one CPU cannot handle this code, modify it accordingly, especially by not using multiprocessing and instead using the threading feature.


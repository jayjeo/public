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
```

### NOTES:
  * These codes use the embedding feature recently developed by Microsoft.
  * Utilizing the OpenAI embedding method does not require GPU computing power, as it employs the server API from OpenAI, which is closed-source. In contrast, the Microsoft method uses an open-source embedding feature that operates directly on your computer without relying on Microsoft's servers. This independence from Microsoft's servers is beneficial, but the downside is that computing speed crucially depends on your own computing power. This is why this code requires a powerful GPU.  
  * I used a server with 100 CPUs and a special GPU as described below. I cannot guarantee that a private local computer with one CPU can handle this code, but it may work well.
    *  AMD EPYC 7742 vCPUs (100 CPUs), A100 SXM4 80 GB (1 GPU), 340 GB RAM
    *  I recommend using a server provided by TensorDock as it is relatively cheap, very reliable, and the staff feedback is fast and good.
  * If a private local computer with one CPU cannot handle this code, modify it accordingly, especially by not using multiprocessing and instead using the threading feature.

### STEPS:
  * Sequentially follow the steps explained in the "ESCO vs ONET comparison" section in master.do.

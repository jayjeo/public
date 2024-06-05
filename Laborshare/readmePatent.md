# General Instructions for Entire Paper.
  * [https://github.com/jayjeo/public/blob/main/Laborshare/readme.md](https://github.com/jayjeo/public/blob/main/Laborshare/readme.md)

# Instructions for Patent related works. 

##### VERSION CONTROLS:
Developed under Python 3.10.9

For Windows, open Command Prompt (cmd) or PowerShell, and type these lines. 
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

##### IMPORTANT NOTES:
Read NOTES 1 through 3 for a faster way. In the meantime, I will share the final data files generated at each step. Therefore, if you want to skip the tedious processes, you can simply download the files from the provided link: 
[https://www.dropbox.com/scl/fo/jmbbjgw6hda3bn30abhv1/AGQ73nI4rysYXWC_rN2fjXE?rlkey=y5vnz4k3xl08j8oyomxypv2h4&st=qtfojwl7&dl=0](https://www.dropbox.com/scl/fo/jmbbjgw6hda3bn30abhv1/AGQ73nI4rysYXWC_rN2fjXE?rlkey=y5vnz4k3xl08j8oyomxypv2h4&st=qtfojwl7&dl=0)

##### GENERAL STEPS:
1) Generate three folders: DownloadXML, SplitXML, and ExtractedXML.   <<< These folders should be already made. 

2) Execute "downloadZIP.py"    <<< This takes about a day. 

3) After downloading is finished, unzip all the files into a folder named DownloadXML. 

4) Execute "parser master.py"   <<< This takes about three days. 
"Skipped: due to missing patent number or IPC information" is a part of the natural process. It is not error.

5) Execute "MatchIndustry.py"

6) Alternatively, you can skip Steps 1 through 5 to save time. You can just download finalized Stata dta file from my Dropbox link. This gives you Industryfound_patents.dta.

7) Execute "MatchSOC_Microsoft.py" This code does embedding tasks using Microsoft open source and calculates similarity scores based on these embedded vectors.    
<<< This process takes about 28 days under the condition of my local personal computer: INTEL i5-13500 (1 CPU) / 32 GB RAM / Nvidia RTX4070 12GB (1 GPU)

8) Execute filter_top_scores_Microsoft.py. This gives you final_similarityresults_Microsoft.dta. 
<<< "filter_top_scores_Microsoft.py" works well with 100 CPUs but may not function correctly with only 1 CPU. The code needs to be modified accordingly for single CPU usage. I do not provide this code. 

9) Steps 7 and 8 require about 150GB free disk space. Alternatively, you can skip Steps 7 and 8, and you can just download the final result from my Dropbox link. This gives you final_similarityresults_Microsoft.dta

10) Execute "MatchSOC_OpenAI.py". In MatchSOC_OpenAI.py, you should set correct OpenAI api key. This python code does embedding tasks using OpenAI closed-source and calculates similarity scores based on these embedded vectors.    
<<< This process takes 10 days under the condition of my personal computer: INTEL i5-13500 (1 CPU) / 32 GB RAM / Nvidia RTX4070 12GB (1 GPU)

11) Execute filter_top_scores_OpenAI.py. This gives you final_similarityresults_OpenAI.dta
<<< "filter_top_scores_OpenAI.py" works well with 100 CPUs but may not function correctly with only 1 CPU. The code needs to be modified accordingly for single CPU usage.

12) Steps 10 and 11 require about 150GB free disk space. Alternatively, you can skip Steps 10 and 11, and you can just download the final result from my Dropbox link. This gives you final_similarityresults_OpenAI.dta

13) Execute Compare_OAI_MS.py and Pythonplot_OAI_MS.py for a figure generation.

14) Execute remaining do files that appears in master.do

##### NOTES 1:
  * Using OpenAI's embedding is fast because it does not depend on the performance of your local computer's GPU (it relies directly on OpenAI's servers). This means you can execute Step 10 using your local computer. In contrast, Microsoft's embedding (Step 7) depends directly on your computer's hardware specifications. Thus, it can be very slow if your computer has low GPU specifications. 

  * To address this issue, you may consider using a GPU server cloud rental service, such as TensorDock or RunPod. I recommend TensorDock for its reliability and faster staff replies. Meanwhile, both servers are more affordable than other cloud services.

  * In general, embedding tasks are heavily dependent on GPUs, and the calculation of the cosine similarity score relies primarily on the CPU. Therefore, when you are working on the embedding part (or the cosine similarity score part), it is advisable to use a computer with a large number of GPUs (or CPUs). Typically, a personal computer has one CPU and one GPU, which will make the work extremely slow.

##### NOTES 2:
To save time on Step 7, you can follow the procedure below. Normally, Step 7 takes about 28 days, but the following method only requires about 36 hours.

7A) Complete Step 7 using a server with GPU (recommend at least AMD EPYC 7513 vCPUs (18 CPUs) / 80 GB RAM / A100 SXM4 80GB (1 GPU)) until the following four files are present in your working directory: patent_embeddings.npy, soc_embeddings.npy, filtered_df.pkl, soc_df.pkl. This process takes about 24 hours. 

7B) Use a CPU cloud server (not a GPU) to execute MatchSOC_Microsoft_server.py. This process takes about 12 hours. I recommend using TensorDock with the following specifications: Intel Xeon Platinum 8470 vCPUs (100 CPUs), 340GB RAM, 150GB SSD. 

If you run MatchSOC_Microsoft.py from Step 7 on this server, the expected processing time would still be around 28 days. This is due to a bottleneck issue found in coding, MatchSOC_Microsoft.py, which cannot utilize 100 CPUs simultaneously. Instead, use MatchSOC_Microsoft_server.py, which has resolved these issues. On the contrary, if you try running MatchSOC_Microsoft_server.py on your local personal computer, the process will likely be terminated automatically. This is because your computer may not meet the code execution requirements of MatchSOC_Microsoft_server.py.

7C) Download the generated data files (1001 files) from the server to your local computer in your working directory. The resulting dataset is provided in Dropbox link. 

##### NOTES 3:
To save time on Step 10, you can follow the procedure below. Normally, Step 10 takes about 10 days, but the following method only requires about 2 days. 

10A) Use a CPU cloud server (not a GPU) to execute MatchSOC_OpenAI_server.py. In MatchSOC_OpenAI_server.py, you should set correct OpenAI api key, and adjust the number of CPUs available in your server using code line 121 (max_workers: int = 100). For instance, it is set as 100. I recommend using TensorDock with the same speficiations explained above (Step 7B). 

If you run MatchSOC_OpenAI.py on this server, the expected processing time would still be 10 days. This is because MatchSOC_OpenAI.py uses only four CPU cores (max_workers: int = 4) and automatically lowers it if your CPU cores are smaller than four.

Unlike Step 7A, described above, utilizing the OpenAI method does not require GPU computing power, as it employs the server API from OpenAI, which is closed-source. In contrast, the Microsoft method (Step 7A) uses an open-source embedding feature that operates directly on your computer without relying on Microsoft's servers. This independence from Microsoft's servers is beneficial, but the downside is that computing speed crucially depends on your own computing power. This is why Step 7B requires a powerful GPU, such as the A100 SXM4 80GB. 

10B) Download the generated data files (1001 files) from the server to your local computer in your working directory. The resulting dataset is provided in Dropbox link. 

##### NOTES 4:
  * In the meantime, I recommend using the "screen" program for Python. After installing it with "pip install screen", you can type "screen" to use it. This program allows you to reconnect to the server without losing currently running Python script when your local computer abruptly disconnects from the server. You can resume your Python execution by typing "screen -r 12345", where 12345 is your PID. PID can be found by typing "screen -ls". For instance, 12345.pts-0.hostname.

  * Additionally, I recommend using WinSCP if your local computer runs a Windows system. WinSCP allows for easy and stable uploads and downloads of extremely large data files. It also enables you to resume uploads and downloads if your local computer experiences an unfortunate disconnection from the server.

  * Finally, I recommend using screen top. This displays the current number of CPUs in use and their usage percentages. First, type screen, and then type top to access this feature.

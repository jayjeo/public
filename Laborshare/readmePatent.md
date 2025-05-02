# General Instructions for Entire Paper.
  * [https://github.com/jayjeo/public/blob/main/Laborshare/readme.md](https://github.com/jayjeo/public/blob/main/Laborshare/readme.md)

# Instructions for patent related works. 

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

### GENERAL STEPS:
0) Follow Steps 1 through 5 on your personal computer. 

1) Generate three folders: DownloadXML, SplitXML, and ExtractedXML.   <<< These folders should already exist. 

2) Execute "downloadZIP.py"    <<< This takes about few hours. 

3) After downloading is finished, unzip all the files into a folder named DownloadXML. 

4) Execute "parser_master.py"   <<< This takes about three days. 
"Skipped: due to missing patent number or IPC information" is a part of the natural process. It is not error.

5) Execute "MatchIndustry.py"

6) Execute "Microsoft.py"
 
7) Alternatively, you can skip Steps 1 through 6 to save time. You can just download finalized Stata dta file from my Dropbox link. This gives you Industryfound_patents_USinclude_publish.dta and Patents_Microsoft_Results_publish.dta.

8) Execute remaining do files that appears in master.do

### NOTES 2:
  * In the meantime, I recommend using the "screen" program for Python. After installing it with "pip install screen", you can type "screen" to use it. This program allows you to reconnect to the server without losing currently running Python script when your local computer abruptly disconnects from the server. You can resume your Python execution by typing "screen -r 12345", where 12345 is your PID. PID can be found by typing "screen -ls". For instance, 12345.pts-0.hostname.

  * Additionally, I recommend using WinSCP if your local computer runs a Windows system. WinSCP allows for easy and stable uploads and downloads of extremely large data files. It also enables you to resume uploads and downloads if your local computer experiences an unfortunate disconnection from the server.

  * Finally, I recommend using screen top. This displays the current number of CPUs in use and their usage percentages. First, type screen, and then type top to access this feature.

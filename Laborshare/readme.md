# Table of contents
- [Table of contents](#table-of-contents)
- [Most Recent Paper](#most-recent-paper)
- [General instructions for Running the Code](#general-instructions-for-running-the-code)
- [Specific instructions for the comparison between ONET and ESCO by using embedding feature.](#specific-instructions-for-the-comparison-between-onet-and-esco-by-using-embedding-feature)
- [Specific instructions for Patent related works.](#specific-instructions-for-patent-related-works)
- [Overview of Required Datasets](#overview-of-required-datasets)
        - [Public access is permitted with appropriate citation.:](#public-access-is-permitted-with-appropriate-citation)
        - [The datasets listed below are not available for public access.](#the-datasets-listed-below-are-not-available-for-public-access)
- [Replication codes and data are provided for reference (Downloading them is not required for this paper).](#replication-codes-and-data-are-provided-for-reference-downloading-them-is-not-required-for-this-paper)

# Most Recent Paper
  * [Automation, Human Task Innovation, and Labor Share: Unveiling the Role of Elasticity of Substitution](https://github.com/ubuzuz/public/blob/main/LaborShare/Automation_Human_Task_Innovation_and_Labor_Share.pdf)

# General instructions for Running the Code
  * Begin by downloading the files using [this link](https://www.dropbox.com/scl/fo/1pp7avt06esszoz1fju2b/AFS-SxHLbvrlEdmdIulogEE?rlkey=fvszr2ab7igw83xr7pd51vn2u&st=9ss50nq6&dl=0)
    * The files in this link has been verified and are free from viruses and malware.
    * Please be aware that initializing the download may take some time due to the large size of the file.
  * After the download is complete, execute the file named 'master.do'.

# Specific instructions for the comparison between ONET and ESCO by using embedding feature. 
  * Follow this link: [https://github.com/jayjeo/public/blob/main/Laborshare/readmeONETESCO.md](https://github.com/jayjeo/public/blob/main/Laborshare/readmeONETESCO.md)
  
# Specific instructions for Patent related works. 
  * Follow this link: [https://github.com/jayjeo/public/blob/main/Laborshare/readmePatent.md](https://github.com/jayjeo/public/blob/main/Laborshare/readmePatent.md)

# Overview of Required Datasets
##### Public access is permitted with appropriate citation.:
  * Datasets such as US-Census, OECD STAN, KLEMS, ONET, UN-Comtrade, and others are open to the public. 
  * We recommend utilizing the KLEMS data and codes provided by us.
    * Although direct download from the website listed below is possible, we advise against this approach.
      * To access the 2023 vintage release of KLEMS, please visit https://euklems-intanprod-llee.luiss.it/.
      * For downloading all available vintages, please refer to the replication code and data provided by Gutiérrez, G., and Piton, S. (2020).
      * Please note that downloading all vintages directly from the official KLEMS webpage may not be efficient, or it could require a considerable amount of time.
##### The datasets listed below are not available for public access.
```diff
- It is impossible to fully replicate the study from scratch without the datasets listed below.
```
  * EU-LFS:
    * Although this dataset is free, accessing it requires an application for data permission, which is typically processed within approximately two months.
    * We are utilizing the 2023 release of this dataset.
    * After downloading, please save the file in the /Secured/EULFS folder located in the current directory.
    * The file format should appear as follows:
      * [![file format](https://github.com/jayjeo/public/raw/main/Laborshare/format.png)](#features)
  * International Federation of Robotics:
    * Accessing this dataset necessitates the purchase of the IFR data, a process that typically takes a few days.
    * We are utilizing the 2023 release of this dataset.
    * After downloading, please save the file in the /Secured folder within the current directory. The file should be named 'IFRdata.csv'.

```diff
- However, it is possible to replicate "regression.do", "accounting.do", "elasticity.do". 
```
  * The final datasets required for processing 'regression.do', 'accounting.do', and 'elasticity.do' are provided in the link below.
    * Specifically, you can replicate the "regression.do" file starting from code line 320 onwards.
    * Specifically, you can replicate the "accounting.do" file starting from code line 140 onwards.
    * Specifically, you can replicate the "elasticity.do" file starting from code line 20 onwards.
  * Please download all files located in the folder named "Eventually required datasets".
  * https://www.dropbox.com/scl/fo/jmbbjgw6hda3bn30abhv1/AGQ73nI4rysYXWC_rN2fjXE?rlkey=y5vnz4k3xl08j8oyomxypv2h4&st=qtfojwl7&dl=0
  * By downloading this data, you can bypass the entire process before "regression.do", "accounting.do", "elasticity.do". 
  * In this way, you will not need to secure an official grant for the EU-Labor Force Survey data, which typically requires about two months of paperwork and waiting time. 
  * Additionally, you will not need to purchase IFR data, which costs about $3,000. 
  * This public release complies with the data protection agreements mandated by the EU-LFS and IFR, as it only contains aggregated information, not detailed data.

# Replication codes and data are provided for reference (Downloading them is not required for this paper). 
* Gutiérrez, G., & Piton, S. (2020). Revisiting the global decline of the (non-housing) labor share. American Economic Review: Insights, 2(3), 321–338.
https://www.aeaweb.org/articles?id=10.1257/aeri.20190285
* Autor, D., Dorn, D., Katz, L. F., Patterson, C., & Reenen, J. V. (2017). Concentrating on the Fall of the Labor Share. American Economic Review, 107(5), 180–185.
https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/6LVZM7
* Karabarbounis, L., & Neiman, B. (2014). The global decline of the labor share. The Quarterly Journal of Economics, 129(1), 61–103.
https://sites.google.com/site/loukaskarabarbounis/research  or  https://brentneiman.com/research-writings/
* Acemoglu, D., & Restrepo, P. (2019). Automation and new tasks: How technology displaces and reinstates labor. Journal of Economic Perspectives, 33(2), 3–30.
https://www.aeaweb.org/articles?id=10.1257/jep.33.2.3
* Acemoglu, D., & Restrepo, P. (2020). Robots and jobs: Evidence from US labor markets. Journal of Political Economy, 128(6), 2188–2244.
https://www.journals.uchicago.edu/doi/10.1086/705715
* Piketty, T., & Zucman, G. (2014). Capital is back: Wealth-income ratios in rich countries 1700–2010. The Quarterly Journal of Economics, 129(3), 1255–1310.
http://piketty.pse.ens.fr/en/capitalisback or if the link does not work, then https://wid.world/


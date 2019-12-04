FROM jupyter/scipy-notebook:17aba6048f44

USER root
RUN conda install -c damianavila82 rise
RUN conda install -c conda-forge bqplot
RUN conda install -c conda-forge ipywidgets
RUN conda install -c conda-forge jupyter_nbextensions_configurator

USER $NB_UID

# "%docker_path%" run -d -v %path%/examples:/home/jovyan/examples -p 80:8888 advent:latest start-notebook.sh --NotebookApp.password="" --NotebookApp.token=""
# "%docker_path%" build --rm -f "Dockerfile" -t advent:latest .
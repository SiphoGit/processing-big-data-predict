FROM python:3.9.1

# Install dependencies
RUN apt-get update && apt-get install -y curl wget

# Upgrade pip 
RUN pip3 install --upgrade pip

# Install required packages
COPY  requirements.txt .
RUN pip3 install -r requirements.txt

# Versions
ENV SPARK_VERSION=3.5.1 \
    HADOOP_VERSION=3 \
    JAVA_VERSION=11

# Set JAVA environment variables
ENV JAVA_HOME="/home/jdk-${JAVA_VERSION}.0.2"
ENV PATH="${JAVA_HOME}/bin/:${PATH}"

# Download and install Java 11
RUN DOWNLOAD_URL="https://download.java.net/java/GA/jdk${JAVA_VERSION}/9/GPL/openjdk-${JAVA_VERSION}.0.2_linux-x64_bin.tar.gz" \
    && TMP_DIR="$(mktemp -d)" \
    && curl -fL "${DOWNLOAD_URL}" --output "${TMP_DIR}/openjdk-${JAVA_VERSION}.0.2_linux-x64_bin.tar.gz" \
    && mkdir -p "${JAVA_HOME}" \
    && tar xzf "${TMP_DIR}/openjdk-${JAVA_VERSION}.0.2_linux-x64_bin.tar.gz" -C "${JAVA_HOME}" --strip-components=1 \
    && rm -rf "${TMP_DIR}" \
    && java --version

# Download and install Spark
RUN DOWNLOAD_URL_SPARK="https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" \
    && wget --no-verbose -O apache-spark.tgz  "${DOWNLOAD_URL_SPARK}"\
    && mkdir -p /home/spark \
    && tar -xf apache-spark.tgz -C /home/spark --strip-components=1 \
    && rm apache-spark.tgz

# Set Spark environment variables
ENV SPARK_HOME="/home/spark"
ENV PATH="${SPARK_HOME}/bin/:${PATH}"

# Set PySpark variables
ENV PYTHONPATH="${SPARK_HOME}/python/:$PYTHONPATH"
ENV PYTHONPATH="${SPARK_HOME}/python/lib/py4j-0.10.9.5-src.zip:$PYTHONPATH"

# Create non-root user
RUN useradd -ms /bin/bash siphodkr

# Switch to non-root user
USER siphodkr

# Set ENTRYPOINT to python
ENTRYPOINT ["python"]

# Set the default command to run JupyterLab
CMD ["-m", "jupyter", "lab", "--no-browser", "--ip=0.0.0.0"]
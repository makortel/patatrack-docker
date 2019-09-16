FROM cmssw/cc7

USER root
RUN groupadd -r cmsinst && useradd --no-log-init -r -g cmsinst cmsinst
RUN groupadd -r cmsbld && useradd --no-log-init -r -g cmsbld cmsbld
RUN chown -R cmsinst.cmsinst /opt/cms


ARG SCRAM_ARCH=slc7_amd64_gcc700
USER    cmsinst
WORKDIR /opt/cms
RUN     wget -O /opt/cms/bootstrap.sh http://cmsrep.cern.ch/cmssw/repos/bootstrap.sh
RUN     sh /opt/cms/bootstrap.sh setup -r cms -architecture $SCRAM_ARCH -server cmsrep.cern.ch 
#RUN     /opt/cms/common/cmspkg -a $SCRAM_ARCH install -y cms+local-cern-siteconf+sm111124
ARG     CMSSW_VERSION=CMSSW_10_5_0_pre2
RUN     /opt/cms/common/cmspkg -a $SCRAM_ARCH install -y cms+cmssw+$CMSSW_VERSION
RUN     /opt/cms/common/cmspkg -a $SCRAM_ARCH -r cms.patatrack install -y cms+cmssw+CMSSW_10_5_0_pre2_Patatrack
RUN     /opt/cms/common/cmspkg -a $SCRAM_ARCH -r cms.patatrack install -y cms+cmssw+CMSSW_10_5_0_pre2_Patatrack_CUDA_10_0
RUN     /opt/cms/common/cmspkg -a $SCRAM_ARCH clean

USER    root
RUN     /bin/cp -f /opt/cms/cmsset_default.sh  /etc/profile.d/
RUN     /bin/cp -f /opt/cms/cmsset_default.csh /etc/profile.d/
RUN     mkdir /opt/shifter
USER    cmsbld

USER cmsinst
RUN    ln -s /cvmfs/cms.cern.ch/SITECONF /opt/cms/SITECONF
USER cmsbld

ENV NVIDIA_REQUIRE_CUDA "cuda>=10.0"
ENV NVIDIA_VISIBLE_DEVICES "all"
ENV NVIDIA_DRIVER_CAPABILITIES "compute,utility"
ENV PATH "/opt/shifter/bin:$PATH"
ENV LD_LIBRARY_PATH "/opt/shifter/lib"
## How to run CMLE TPU for Object Detection

Follow https://medium.com/tensorflow/training-and-serving-a-realtime-mobile-object-detector-in-30-minutes-with-cloud-tpus-b78971cf1193?fbclid=IwAR1tB0oDtpGT4rbQGnlqbOrMypkuZVXSUF2M-udtAl1Tdd6qAUEtMQBb61Q 

### Further explanation or guide

EXAMPLE:
Your_project_name : melb-flower-02
Your unique_bucket_Name : flower_bucket
Project id = the id in gcp for your project
YOUR_GCS_BUCKET = step 2 bucket name
TPU account = “ abc@cloud … com “

Every time a terminal is launched, for tensorflow usage : cd to tensorflow/models/research/ and run command “export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim”  and test using python object_detection/builders/model_builder_test.py

PATH_TO_BE_CONFIGURED format is "gs://YOUR_GCS_BUCKET/data/train*"

### Possible problems
  
Problem with coco api 

Follow https://github.com/matterport/Mask_RCNN/issues/6 follow pirahagvp after copying the quantized config file

Problem with the file models/research/object_detection/dataset_tools/create_pycocotools_package.sh.
Check and change accordingly
1) https://stackoverflow.com/questions/51430391/tensorflow-object-detection-training-error-with-tpu/51433826
2) https://www.docketrun.com/blog/pycocotools-2-0-tar-gz-package-using-cocoapi-setup/   
	we need the pycocotools and put that to the folder where you will call it in your cloud config file

### For the training step use 

If using MAC, make sure you understand relative and absolute pathing(Eg that ./tmp and /tmp means a lot of difference!)

gcloud ml-engine jobs submit training `whoami`_object_detection_ssd_fpn_resnet_`date +%s` \
--job-dir=gs://${YOUR_GCS_BUCKET}/train \
--packages dist/object_detection-0.1.tar.gz,slim/dist/slim-0.1.tar.gz,./tmp/pycocotools/pycocotools-2.0.tar.gz \
--module-name object_detection.model_tpu_main \
--runtime-version 1.12 \
--scale-tier BASIC_TPU \
--region us-central1 \
-- \
--model_dir=gs://${YOUR_GCS_BUCKET}/train \
--tpu_zone us-central1 \
--pipeline_config_path=gs://${YOUR_GCS_BUCKET}/data/pipeline.config


gcloud ml-engine jobs submit training `whoami`_object_detection_eval_validation_fpn_resnet_`date +%s` \
--job-dir=gs://${YOUR_GCS_BUCKET}/train \
--packages dist/object_detection-0.1.tar.gz,slim/dist/slim-0.1.tar.gz,./tmp/pycocotools/pycocotools-2.0.tar.gz \
--module-name object_detection.model_main \
--runtime-version 1.12 \
--scale-tier BASIC_GPU \
--region us-central1 \
-- \
--model_dir=gs://${YOUR_GCS_BUCKET}/train \
--pipeline_config_path=gs://${YOUR_GCS_BUCKET}/data/pipeline.config \
--checkpoint_dir=gs://${YOUR_GCS_BUCKET}/train

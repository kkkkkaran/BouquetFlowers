import tensorflow as tf
from tensorflow.python.saved_model import signature_constants
from tensorflow.python.saved_model import tag_constants
import numpy as np


export_dir = './saved'
graph_pb = 'yolov3_coco.pb'
graph           = tf.Graph()

builder = tf.saved_model.builder.SavedModelBuilder(export_dir)


with tf.gfile.GFile(graph_pb, "rb") as f:
    graph_def = tf.GraphDef()
    graph_def.ParseFromString(f.read())

sigs = {}

with tf.Session(graph=tf.Graph()) as sess:
    tf.import_graph_def(graph_def, name="")
    g = tf.get_default_graph()
    
    out1 = g.get_tensor_by_name("input/input_data:0")
    out2 = g.get_tensor_by_name("pred_sbbox/concat_2:0")
    out3 = g.get_tensor_by_name("pred_mbbox/concat_2:0")
    out4 = g.get_tensor_by_name("pred_lbbox/concat_2:0")     
    


    print(out1)
    
    sigs[signature_constants.DEFAULT_SERVING_SIGNATURE_DEF_KEY] = \
        tf.saved_model.signature_def_utils.predict_signature_def(
            inputs={"input": out1}, outputs={"sbbox":out2,"mbbox":out3,"lbbox":out4})

    builder.add_meta_graph_and_variables(sess,
                                         [tag_constants.SERVING],
                                         signature_def_map=sigs)

builder.save()

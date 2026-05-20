from typing import Optional
import os
import tempfile
import numpy as np
import tensorflow as tf
import cv2
from tensorflow.keras.preprocessing import image as keras_image


class GradCamGenerator:
    def __init__(self, model, last_conv_layer_name: str) -> None:
        self.model = model
        self.last_conv_layer = model.get_layer(last_conv_layer_name)
        self.grad_model = tf.keras.models.Model(
            [model.inputs], [self.last_conv_layer.output, model.output]
        )

    def generate(self, img_path: str) -> Optional[str]:
        img = keras_image.load_img(img_path, target_size=(224, 224), color_mode="rgb")
        arr = keras_image.img_to_array(img)
        arr = np.expand_dims(arr, axis=0)
        arr = arr / 255.0

        with tf.GradientTape() as tape:
            conv_outputs, predictions = self.grad_model(arr)
            top_index = tf.argmax(predictions[0])
            loss = predictions[:, top_index]

        grads = tape.gradient(loss, conv_outputs)
        pooled = tf.reduce_mean(grads, axis=(0, 1, 2))
        conv_outputs = conv_outputs[0]
        heatmap = conv_outputs @ pooled[..., tf.newaxis]
        heatmap = tf.squeeze(heatmap)
        heatmap = tf.maximum(heatmap, 0) / (tf.math.reduce_max(heatmap) + 1e-6)
        heatmap = heatmap.numpy()

        original = cv2.imread(img_path)
        if original is None:
            return None
        original = cv2.resize(original, (224, 224))
        heatmap_resized = cv2.resize(heatmap, (224, 224))
        heatmap_colored = cv2.applyColorMap(np.uint8(255 * heatmap_resized), cv2.COLORMAP_JET)
        overlay = np.clip(0.4 * heatmap_colored + original, 0, 255).astype(np.uint8)

        fd, output_path = tempfile.mkstemp(suffix=".png")
        os.close(fd)
        cv2.imwrite(output_path, overlay)
        return output_path

import cv2
import numpy as np


def homomorphic_filter(image: np.ndarray, d0: int = 30, rh: float = 2.0, rl: float = 0.5, c: float = 1.0) -> np.ndarray:
    image = np.float32(image) / 255.0
    rows, cols = image.shape
    u = np.arange(rows) - rows // 2
    v = np.arange(cols) - cols // 2
    U, V = np.meshgrid(u, v, sparse=False, indexing='ij')
    D = np.sqrt(U ** 2 + V ** 2)
    H = (rh - rl) * (1 - np.exp(-c * (D ** 2 / d0 ** 2))) + rl

    image_log = np.log1p(image)
    image_fft = np.fft.fft2(image_log)
    image_fft_shift = np.fft.fftshift(image_fft)
    image_filtered = image_fft_shift * H
    image_ifft_shift = np.fft.ifftshift(image_filtered)
    image_result = np.fft.ifft2(image_ifft_shift)
    image_result = np.exp(np.real(image_result)) - 1

    image_result = (image_result - np.min(image_result)) / (np.max(image_result) - np.min(image_result) + 1e-6)
    return (image_result * 255).astype(np.uint8)

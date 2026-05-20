from typing import List
import numpy as np


def aco_ewt_decompose(image: np.ndarray, bands: int = 3) -> List[np.ndarray]:
    spectrum = np.fft.fftshift(np.fft.fft2(image))
    magnitude = np.abs(spectrum)
    rows, cols = image.shape
    center = (rows // 2, cols // 2)
    radii = _select_radii_aco(magnitude, bands)
    subbands = []
    for i in range(bands):
        low = radii[i - 1] if i > 0 else 0
        high = radii[i]
        mask = _bandpass_mask(rows, cols, center, low, high)
        filtered = spectrum * mask
        band_img = np.real(np.fft.ifft2(np.fft.ifftshift(filtered)))
        band_img = np.clip(band_img, 0, 255).astype(np.uint8)
        subbands.append(band_img)
    return subbands


def _bandpass_mask(rows: int, cols: int, center: tuple[int, int], low: float, high: float) -> np.ndarray:
    Y, X = np.ogrid[:rows, :cols]
    dist = np.sqrt((X - center[1]) ** 2 + (Y - center[0]) ** 2)
    mask = (dist >= low) & (dist < high)
    return mask.astype(np.float32)


def _select_radii_aco(magnitude: np.ndarray, bands: int) -> List[float]:
    rows, cols = magnitude.shape
    max_radius = min(rows, cols) / 2
    pheromone = np.ones(int(max_radius))
    best_radii = None
    best_score = -1

    for _ in range(20):
        radii = _construct_solution(pheromone, bands)
        score = _evaluate_radii(magnitude, radii)
        if score > best_score:
            best_score = score
            best_radii = radii
        pheromone = _update_pheromone(pheromone, radii, score)

    return best_radii or _fallback_radii(bands, max_radius)


def _construct_solution(pheromone: np.ndarray, bands: int) -> List[float]:
    probabilities = pheromone / pheromone.sum()
    choices = np.random.choice(len(pheromone), size=bands, replace=False, p=probabilities)
    radii = sorted([float(c) for c in choices])
    return radii


def _evaluate_radii(magnitude: np.ndarray, radii: List[float]) -> float:
    rows, cols = magnitude.shape
    center = (rows // 2, cols // 2)
    score = 0.0
    prev = 0.0
    for r in radii:
        mask = _bandpass_mask(rows, cols, center, prev, r)
        score += float((magnitude * mask).sum())
        prev = r
    return score


def _update_pheromone(pheromone: np.ndarray, radii: List[float], score: float) -> np.ndarray:
    evaporation = 0.9
    pheromone = pheromone * evaporation
    for r in radii:
        idx = int(min(max(r, 0), len(pheromone) - 1))
        pheromone[idx] += score * 1e-6
    return pheromone


def _fallback_radii(bands: int, max_radius: float) -> List[float]:
    step = max_radius / bands
    return [step * (i + 1) for i in range(bands)]

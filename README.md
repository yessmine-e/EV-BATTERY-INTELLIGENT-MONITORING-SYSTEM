# Notebook: EV_Battery — Project README

This README documents everything performed in the notebook(s) located in this folder. It summarizes the purpose, dataset, preprocessing, model architecture, training and evaluation procedures, the companion Flutter mobile application, and instructions to reproduce the results locally.

## 1. Project goal

Predict lithium-ion battery **State of Charge (SOC)** and **State of Health (SOH)** from a public battery dataset, derive **Remaining Useful Life (RUL)** and driving range estimates from these predictions, and expose the results through a Flutter mobile application (Battery Status and Driving Range & Predictions screens).

## 2. Environment & main dependencies

- Python (3.7+ recommended)
- PyTorch
- XGBoost, LightGBM, scikit-learn
- pandas, numpy
- matplotlib, seaborn
- Flutter SDK (for the mobile application)
- Firebase (backend for the mobile application)

Minimal pip requirements (as used in the notebook):

\`\`\`bash
pip install torch xgboost lightgbm scikit-learn pandas numpy matplotlib seaborn
\`\`\`

## 3. Dataset

The notebook uses a public lithium-ion battery dataset containing voltage, current, temperature, and charge/discharge cycle measurements used to derive SOC and SOH labels.

Update the dataset path in the notebook's data-loading cell to match your local directory structure before running.

## 4. High-level steps done in the notebook

- Setup and imports (PyTorch, XGBoost, LightGBM, pandas, etc.).
- Exploratory data analysis (EDA) on voltage, current, temperature, and cycle features.
- Identification of strongly under-represented target ranges in the SOC/SOH distributions (imbalanced regression).
- Data augmentation for continuous targets: kernel density estimation (KDE), SMOTE-derived oversampling adapted to regression, and Gaussian noise injection, with synthetic samples clipped to physically realistic values.
- Feature engineering from raw sensor measurements.
- Train/validation/test split.
- Training and comparison of multiple models: a deep neural network (DNN), XGBoost, Random Forest, and LightGBM regressors.
- Derivation of Remaining Useful Life (RUL) and driving range from SOC/SOH predictions.
- Evaluation using standard regression metrics.
- Visualization of predictions against ground truth and training curves.
- Export of the trained model(s) for use by the mobile application backend.

## 5. Important functions & components (what the notebook implements)

- **Preprocessing utilities**: functions to clean raw sensor readings, engineer features (e.g., rolling statistics on voltage/current/temperature), and normalize inputs.
- **`kde_oversample(...)`**: estimates the density of the continuous target distribution and generates synthetic samples in under-represented ranges.
- **`smote_regression(...)`**: SMOTE-derived interpolation adapted to continuous SOC/SOH targets, followed by physical-plausibility clipping.
- **`add_gaussian_noise(...)`**: injects controlled Gaussian noise for additional augmentation.
- **Model definitions**: a feed-forward DNN (PyTorch) alongside XGBoost, Random Forest, and LightGBM regressors, trained and compared under the same train/test split.
- **`estimate_rul(...)`**: derives Remaining Useful Life from SOH predictions.
- **`estimate_driving_range(...)`**: derives estimated driving range from SOC predictions.

Compilation / training setup (DNN):

- Loss: mean squared error (MSE)
- Optimizer: Adam
- Metrics: RMSE, MAE, R²

## 6. Data augmentation parameters used

- KDE bandwidth: tuned per target distribution
- Oversampling ratio: applied to under-represented target ranges only
- Gaussian noise: small standard deviation relative to feature scale, applied only to synthetic samples
- Clipping: synthetic samples clipped to physically realistic SOC/SOH bounds (0–100%) to avoid implausible battery states

## 7. Training setup and hyperparameters

- Train/validation/test split: standard split with fixed random seed for reproducibility
- Batch size and epochs (DNN): set in the notebook's configuration cell
- Early stopping: monitored on validation loss to avoid overfitting
- Cross-model comparison: DNN, XGBoost, Random Forest, and LightGBM evaluated under identical splits and preprocessing

## 8. Evaluation

Two complementary evaluations are performed:

- **Standard regression metrics**: RMSE, MAE, and R² computed for SOC and SOH predictions on the test set, for each of the four models.
- **RUL and driving range validation**: predictions derived from SOC/SOH outputs are compared against expected degradation trends to sanity-check downstream estimates.

## 9. Visualizations

- Predicted vs. actual SOC/SOH scatter plots and error distributions.
- Training curves (loss, RMSE) across epochs for the DNN.
- Comparison bar charts of RMSE/MAE/R² across the four models.
- Effect of KDE/SMOTE-derived augmentation shown via before/after distribution plots of the target variable.

## 10. Model saving

The best-performing model(s) are saved for use by the mobile application backend (e.g., as `.pkl` for tree-based models or a serialized PyTorch checkpoint for the DNN). Adjust the save path to a writable directory when running locally.

## 11. Mobile application (Flutter)

The `mobile_app/` folder contains the Flutter source code for the companion application, which consumes the trained model's predictions and displays:

- **Battery Status** screen: SOC, SOH, charge duration, charge cycles, temperature, voltage, current.
- **Driving Range & Predictions** screen: remaining driving range, estimated time to destination, RUL, and SOC/SOH forecasts for the next hour.

The application uses Firebase for data storage and synchronization.

## 12. Reproduce locally (recommended steps)

1. Create a Python environment and install dependencies (see section 2).
2. Download the public battery dataset and update the dataset path in the notebook.
3. Open the notebook in Jupyter / VS Code / Colab and run cells in order.
4. To run the mobile application:

\`\`\`bash
cd mobile_app
flutter pub get
flutter run
\`\`\`

## 13. Contract / expected inputs & outputs (short)

- **Inputs**: tabular battery measurements (voltage, current, temperature, charge/discharge cycle count) from the public dataset.
- **Outputs**: trained regression models (DNN, XGBoost, Random Forest, LightGBM), SOC/SOH/RUL predictions, evaluation metrics, and visualizations; the Flutter application consuming these outputs for real-time-style display.

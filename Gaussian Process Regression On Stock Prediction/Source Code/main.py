from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import RBF, Matern
import matplotlib.pyplot as plt
import pandas as pd
import os
from os.path import isfile, join


def read_data(path):
    # Read data from csv
    dfs = {}
    for file in os.listdir(path):
        if isfile(join(path, file)):
            df = pd.read_csv(join(path, file))
            df['Date'] = pd.to_datetime(df['Date'])
            df.rename({'Close/Last': 'Price'}, axis=1, inplace=True)
            df['Price'] = df['Price'].str.split('$').str[-1].astype('float')
            dfs[file.split('.')[0]] = df[['Date', 'Price']][::-1].set_index('Date')
    print("实验中使用股票为: " + ", ".join(list(dfs.keys())))
    for key in dfs:
        dfs[key].plot()
        plt.ylabel("Stock Prices")
        plt.title("Raw " + key.upper() + " Stock Prices")
        plt.show()
    return dfs


def prepare_data(df, stock_name):
    df = df.resample("M").mean().dropna(axis="index", how="any")
    X = (df.index.year + df.index.month / 12).to_numpy().reshape(-1, 1)
    y = df['Price'].to_numpy()
    df.plot()
    plt.ylabel("Stock Prices")
    plt.title("Monthly Average " + stock_name.upper() + " Stock Prices")
    plt.show()
    return X, y


def gaussian_regression(X, y, train_data_count, mode):
    # GP model kernel
    if mode=="rbf":
        stock_kernel = 1 * RBF(length_scale=2) + 1 * RBF(length_scale=0.1)
    elif mode=="matern":
        stock_kernel=1 * Matern(length_scale=2, nu=1.5) + 1 * Matern(length_scale=0.1, nu=1.5)
    else:
        print("Invalid Kernel Mode")
        return 0
    gp = GaussianProcessRegressor(kernel=stock_kernel, alpha=1e-10, n_restarts_optimizer=10, normalize_y=True, random_state=7)
    gp.fit(X[:train_data_count],y[:train_data_count])
    mean_y_pred, std_y_pred = gp.predict(X, return_std=True)
    print("训练后的协方差函数：", gp.kernel_)
    print("R2: ", gp.score(X[train_data_count:],y[train_data_count:]))
    print("log似然: ",gp.log_marginal_likelihood_value_)
    return mean_y_pred, std_y_pred


def plot_result(X_ori, y_ori, X_pred, mean_y_pred, std_y_pred, stock_name, mode):
    plt.plot(X_ori, y_ori, color="black", linestyle="dotted", label="Original Measurements")
    plt.plot(X_pred, mean_y_pred, color="tab:blue", alpha=0.4, label="Gaussian Process Prediction")
    plt.fill_between(
        X_pred.ravel(),
        mean_y_pred - std_y_pred,
        mean_y_pred + std_y_pred,
        color="tab:blue",
        alpha=0.2,
    )
    plt.xlabel("Date")
    plt.ylabel("Stock Prices")
    plt.title("Original and Predicted " + stock_name.upper() + " Stock Prices - "+mode.upper())
    plt.show()


def main():
    DATA_PATH = './GP_data'
    KERNEL_MODES=["rbf","matern"]
    dfs = read_data(DATA_PATH)
    for key in dfs:
        print("股票: ", key.upper())
        print("-"*30)
        X, y=prepare_data(dfs[key], key)
        train_data_count=int(X.shape[0]*0.8)
        print("训练数据量为 ",train_data_count)
        for mode in KERNEL_MODES:
            print("核函数：", mode.upper())
            print("*" * 20)
            mean_y_pred, std_y_pred=gaussian_regression(X, y, train_data_count, mode)
            plot_result(X, y, X, mean_y_pred, std_y_pred, key, mode)
        print("\n")


if __name__ == '__main__':
    main()


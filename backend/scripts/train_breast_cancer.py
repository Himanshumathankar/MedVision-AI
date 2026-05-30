import argparse
from services.training import Trainer


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--dataset",
        action="append",
        required=True,
        help="Path to dataset root with Cancer/Non-Cancer folders (repeatable)",
    )
    args = parser.parse_args()

    trainer = Trainer()
    trainer.train(args.dataset)


if __name__ == "__main__":
    main()

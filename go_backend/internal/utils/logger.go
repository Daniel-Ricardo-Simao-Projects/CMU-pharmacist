package utils

import (
	"github.com/gookit/slog"
)

func Info(message string) {
	slog.Info(message)
}

func Error(message string) {
	slog.Error(message)
}

func Warn(message string) {
	slog.Warn(message)
}

func Debug(message string) {
	slog.Debug(message)
}

func Trace(message string) {
	slog.Trace(message)
}

func Fatal(message string) {
	slog.Fatal(message)
}

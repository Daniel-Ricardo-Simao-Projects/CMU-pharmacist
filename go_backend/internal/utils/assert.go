package utils

func Assert(condition bool, message string) {
	if !condition {
		Error(message)
	}
}

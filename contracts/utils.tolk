import "structs";
import "constants";

fun incrementStorage(ref data: Storage, sender: address) {
  if (sender != data.owner) {
		throw ERR_UNAUTHORIZED;
	}

	if (data.counter === MAX_UNIT_64) {
		throw ERR_OVERFLOW;
	}

	data.counter += 1;
}

fun isDebounce(flags: int) {
	return (flags & 1) != 0;
}

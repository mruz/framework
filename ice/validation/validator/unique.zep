
namespace Ice\Validation\Validator;

use Ice\Di;
use Ice\Validation;
use Ice\Validation\Validator;

class Unique extends Validator
{

    public function validate(<Validation> validation, string! field)
    {
        var value, label, message, replace, di, db, from, custom, except, result, id;

        let value = validation->getValue(field);

        if value === "" || value === null {
            return true;
        }

        let di = Di::$fetch(),
            db = di->{"getDb"}();

        if this->has(0) {
            let from = this->get(0);
        } else {
            let from = this->get("from");
        }

        // Specifying a custom column name
        if this->has(1) {
            let custom = this->get(1);
        } else {
            let custom = this->get("custom");
        }
        if empty custom {
            let custom = field;
        }

        // Forcing a unique rule to ignore a given value
        if this->has(2) {
            let except = this->get(2);
        } else {
            let except = this->get("except");
        }

        if except {
            let id = ["!=": except],
                result = db->findOne(from, [custom: value, "id": id]);
        } else {
            let result = db->findOne(from, [custom: value]);
        }

        if result {
            if this->has("label") {
                let label = this->get("label");
            } else {
                let label = validation->getLabel(field);
            }

            if this->has("message") {
                let message = this->get("message");
            } else {
                let message = validation->getDefaultMessage("unique");
            }

            let replace = [":field": label];

            validation->addMessage(field, strtr(message, replace));
            return false;
        }

        return true;
    }
}
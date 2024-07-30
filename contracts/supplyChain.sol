// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract SupplyChain {

    // Struct representing a step in the supply chain
    struct Step {
        Status status;    // The status of the product in this step
        string metadata;  // Additional information about this step
        uint256 price;    // The price associated with this step
        address author;   // The address of the entity that recorded this step
    }

    // Struct representing a product in the supply chain
    struct Product {
        Step[] steps;                       // Array of steps the product has gone through
        mapping(Status => uint256) prices;  // Mapping from Status to the price for that status
    }

    // Enum representing the different possible statuses in the supply chain
    enum Status {
        CREATED,              // The product has been created
        READY_FOR_PICK_UP,    // The product is ready to be picked up
        PICKED_UP,            // The product has been picked up
        READY_FOR_DELIVERY,   // The product is ready to be delivered
        DELIVERED             // The product has been delivered
    }

    // Event emitted when a new step is registered
    event RegisteredStep (
        uint productId,      // The ID of the product
        Status status,       // The status of the product in this step
        string metadata,     // Additional information about this step
        address author,      // The address of the entity that recorded this step
        uint256 price        // The price associated with this step
    );

    // Mapping from product ID to the product data
    mapping(uint => Product) private products;

    // Function to register a new product
    function registerProduct(
        uint productId,
        uint256 readyForPickUpPrice,
        uint256 pickedUpPrice,
        uint256 readyForDeliveryPrice,
        uint256 deliveredPrice
    ) public returns (bool success) {
        // Ensure the product does not already exist
        require(products[productId].steps.length == 0, "This product already exists");

        // Initialize the product with the CREATED status
        Product storage product = products[productId];
        product.steps.push(Step(Status.CREATED, "", 0, msg.sender));

        // Set the prices for the different statuses
        product.prices[Status.READY_FOR_PICK_UP] = readyForPickUpPrice;
        product.prices[Status.PICKED_UP] = pickedUpPrice;
        product.prices[Status.READY_FOR_DELIVERY] = readyForDeliveryPrice;
        product.prices[Status.DELIVERED] = deliveredPrice;

        return true;
    }

    // Function to register a new step for a product
    function registerStep(
        uint productId,
        string calldata metadata
    ) public payable returns (bool success) {
        // Ensure the product exists
        require(products[productId].steps.length > 0, "This product does not exist");

        // Get the product and its steps
        Product storage product = products[productId];
        Step[] storage stepsArray = product.steps;

        // Determine the next status for the product
        uint currentStatus = uint(stepsArray[stepsArray.length - 1].status) + 1;
        if (currentStatus > uint(Status.DELIVERED)) {
            revert("The product has no more steps");
        }

        Status nextStatus = Status(currentStatus);

        // Get the required price for the next status
        uint256 requiredPrice = product.prices[nextStatus];

        // Ensure the sender has paid the required price
        if (msg.value < requiredPrice) {
            revert("You need to pay the required price");
        }

        // If a payment is required, transfer the amount to the previous step's author
        if (requiredPrice > 0) {
            address payable _to = payable(stepsArray[currentStatus - 1].author);
            _to.transfer(requiredPrice);
        }

        // Register the new step
        Step memory newStep = Step(
            nextStatus,
            metadata,
            requiredPrice,
            msg.sender
        );
        product.steps.push(newStep);

        // Emit the event for the new step
        emit RegisteredStep(
            productId,
            nextStatus,
            metadata,
            msg.sender,
            requiredPrice
        );

        return true;
    }

    // Public function to get details of a specific step for a product
    function getStep(uint productId, uint stepIndex) public view returns (Status, string memory, uint256, address) {
        Step storage step = products[productId].steps[stepIndex];
        return (step.status, step.metadata, step.price, step.author);
    }

    // Public function to get the number of steps a product has gone through
    function getStepsCount(uint productId) public view returns (uint) {
        return products[productId].steps.length;
    }

    // Public function to get the price associated with a specific status for a product
    function getPrice(uint productId, Status status) public view returns (uint256) {
        return products[productId].prices[status];
    }
}

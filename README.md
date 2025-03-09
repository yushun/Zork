# Rails Zork

A web-based implementation of a Zork-like text adventure game built with Ruby on Rails. This project recreates the classic interactive fiction experience in a modern web interface.

## 🎮 Game Features

- Text-based adventure gameplay
- Classic command parser supporting actions like:
  - `go [direction]` - Move between locations
  - `take [item]` - Pick up items
  - `drop [item]` - Drop items from inventory
  - `look` - Examine your surroundings
  - `inventory` - Check what you're carrying
  - `examine [item]` - Look at items in detail
  - `use [item]` - Use items in your inventory
  - `talk to [person]` - Interact with NPCs
  - `help` - Show available commands

## 🛠 Technical Requirements

- Ruby 3.3.7
- Rails 8.0.1
- SQLite3
- Node.js (for asset compilation)

## 📦 Installation

1. Clone the repository:
```bash
git clone [your-repo-url]
cd zork
```

2. Install dependencies:
```bash
bundle install
```

3. Set up the database:
```bash
rails db:create
rails db:migrate
rails db:seed  # If you have seed data
```

4. Start the Rails server:
```bash
rails server
```

5. Visit `http://localhost:3000` in your browser to start playing!

## 🎯 Game Structure

The game is built using a Model-View-Controller (MVC) architecture:
- `Player` model manages inventory and player state
- `Room` model handles locations and navigation
- `Item` model manages collectible objects
- `GameController` processes player commands

## 🧪 Testing

[To be implemented]

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE.md file for details.

## 🎉 Acknowledgments

- Inspired by the original Zork game by Infocom
- Built with Ruby on Rails
- Special thanks to the interactive fiction community

## 🔄 Status

Project is: _in development_ 
# 🦀 The Complete Rust Guide: Your Rust Bible

A comprehensive, practical guide to mastering Rust programming from fundamentals to advanced patterns. This guide covers everything you need to build robust, performant, and safe systems in Rust.

## 📚 Table of Contents

1. [🧠 Core Mental Models](#-core-mental-models)
2. [📋 Ownership & Borrowing Mastery](#-ownership--borrowing-mastery)
3. [🎯 Types & Pattern Matching](#-types--pattern-matching)
4. [⚡ Memory Management Patterns](#-memory-management-patterns)
5. [🔀 Concurrency & Async](#-concurrency--async)
6. [📦 Crates & Modules](#-crates--modules)
7. [🧪 Testing & Benchmarking](#-testing--benchmarking)
8. [🔧 Error Handling](#-error-handling)
9. [🚀 Performance Optimization](#-performance-optimization)
10. [🏗️ API Design Patterns](#-api-design-patterns)
11. [🔒 Unsafe Rust](#-unsafe-rust)
12. [📡 Network & I/O](#-network--io)
13. [🛠️ Build System & Cargo](#-build-system--cargo)
14. [🐛 Debugging & Profiling](#-debugging--profiling)
15. [🌍 Real-World Patterns](#-real-world-patterns)
16. [✅ Best Practices Checklist](#-best-practices-checklist)

---

## 🧠 Core Mental Models

### 🎯 The Rust Philosophy

**🔒 Memory Safety Without GC:** Rust prevents memory errors at compile time without runtime garbage collection.

**⚡ Zero-Cost Abstractions:** High-level features compile down to efficient machine code.

**🔄 Move Semantics:** Values have unique owners; transfers of ownership are explicit.

**🛡️ Fearless Concurrency:** The type system prevents data races and ensures thread safety.

**📊 Systems Programming:** Direct hardware access with high-level ergonomics.

### 🎨 Key Concepts

```rust
// Ownership: Every value has a single owner
let data = String::from("hello");  // `data` owns the string
let moved = data;                  // Ownership moved to `moved`
// println!("{}", data);           // Error: `data` no longer valid

// Borrowing: References allow temporary access
let data = String::from("hello");
let borrowed = &data;              // Immutable borrow
let len = borrowed.len();          // OK to use borrowed reference
println!("{}", data);              // Original owner still valid

// Lifetimes: References must not outlive their data
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}
```

---

## 📋 Ownership & Borrowing Mastery

### 🎯 The Three Rules

1. **Each value has exactly one owner**
2. **When the owner goes out of scope, the value is dropped**
3. **There can be either one mutable reference OR any number of immutable references**

### 🔄 Ownership Patterns

```rust
// Pattern 1: Transfer ownership for transformation
fn process_data(mut data: Vec<String>) -> Vec<String> {
    data.push("processed".to_string());
    data  // Return transformed data
}

// Pattern 2: Borrow for inspection
fn analyze_data(data: &[String]) -> usize {
    data.iter().map(|s| s.len()).sum()
}

// Pattern 3: Mutable borrow for in-place modification
fn modify_data(data: &mut Vec<String>) {
    data.retain(|s| !s.is_empty());
}

// Pattern 4: Clone when you need independent copies
fn backup_data(data: &Vec<String>) -> Vec<String> {
    data.clone()  // Explicit cost of duplication
}
```

### 🏗️ Builder Pattern with Ownership

```rust
pub struct Config {
    host: String,
    port: u16,
    timeout: Duration,
}

impl Config {
    pub fn new() -> ConfigBuilder {
        ConfigBuilder::default()
    }
}

#[derive(Default)]
pub struct ConfigBuilder {
    host: Option<String>,
    port: Option<u16>,
    timeout: Option<Duration>,
}

impl ConfigBuilder {
    pub fn host(mut self, host: String) -> Self {
        self.host = Some(host);
        self
    }

    pub fn port(mut self, port: u16) -> Self {
        self.port = Some(port);
        self
    }

    pub fn build(self) -> Result<Config, &'static str> {
        Ok(Config {
            host: self.host.ok_or("host required")?,
            port: self.port.unwrap_or(8080),
            timeout: self.timeout.unwrap_or(Duration::from_secs(30)),
        })
    }
}

// Usage
let config = Config::new()
    .host("localhost".to_string())
    .port(3000)
    .build()?;
```

### 🔄 Smart Pointers

```rust
use std::rc::{Rc, Weak};
use std::sync::{Arc, Mutex};
use std::cell::RefCell;

// Rc<T>: Reference counting for shared ownership (single-threaded)
let shared = Rc::new("shared data".to_string());
let ref1 = Rc::clone(&shared);
let ref2 = Rc::clone(&shared);

// Arc<T>: Atomic reference counting (thread-safe)
let shared = Arc::new(Mutex::new(vec![1, 2, 3]));
let shared_clone = Arc::clone(&shared);

thread::spawn(move || {
    shared_clone.lock().unwrap().push(4);
});

// Box<T>: Heap allocation with unique ownership
let boxed: Box<dyn Display> = Box::new(42);

// RefCell<T>: Interior mutability with runtime borrow checking
let data = RefCell::new(vec![1, 2, 3]);
data.borrow_mut().push(4);  // Runtime checked mutable borrow
```

---

## 🎯 Types & Pattern Matching

### 🎨 Advanced Enums

```rust
#[derive(Debug, Clone)]
pub enum Message {
    Text { content: String, urgent: bool },
    Image { url: String, alt_text: Option<String> },
    File { name: String, size: u64, mime_type: String },
    System(SystemEvent),
}

#[derive(Debug, Clone)]
pub enum SystemEvent {
    UserJoined(String),
    UserLeft(String),
    RoomCreated { name: String, private: bool },
}

// Pattern matching with guards and destructuring
fn process_message(msg: Message) -> String {
    match msg {
        Message::Text { content, urgent: true } => {
            format!("URGENT: {}", content.to_uppercase())
        },
        Message::Text { content, urgent: false } => content,

        Message::Image { url, alt_text: Some(alt) } => {
            format!("Image: {} ({})", url, alt)
        },
        Message::Image { url, alt_text: None } => {
            format!("Image: {}", url)
        },

        Message::File { name, size, .. } if size > 1_000_000 => {
            format!("Large file: {} ({} MB)", name, size / 1_000_000)
        },
        Message::File { name, size, mime_type } => {
            format!("File: {} ({} bytes, {})", name, size, mime_type)
        },

        Message::System(SystemEvent::UserJoined(user)) => {
            format!("{} joined the chat", user)
        },
        Message::System(SystemEvent::UserLeft(user)) => {
            format!("{} left the chat", user)
        },
        Message::System(SystemEvent::RoomCreated { name, private: true }) => {
            format!("Private room '{}' created", name)
        },
        Message::System(SystemEvent::RoomCreated { name, private: false }) => {
            format!("Public room '{}' created", name)
        },
    }
}
```

### 🎭 Trait Objects & Generics

```rust
// Trait for common behavior
pub trait Processor {
    fn process(&self, input: &str) -> Result<String, ProcessError>;
    fn name(&self) -> &str;

    // Default implementation
    fn process_batch(&self, inputs: &[String]) -> Vec<Result<String, ProcessError>> {
        inputs.iter()
            .map(|input| self.process(input))
            .collect()
    }
}

// Concrete implementations
pub struct JsonProcessor;
impl Processor for JsonProcessor {
    fn process(&self, input: &str) -> Result<String, ProcessError> {
        // JSON processing logic
        Ok(format!("JSON: {}", input))
    }

    fn name(&self) -> &str { "json" }
}

pub struct XmlProcessor;
impl Processor for XmlProcessor {
    fn process(&self, input: &str) -> Result<String, ProcessError> {
        Ok(format!("XML: {}", input))
    }

    fn name(&self) -> &str { "xml" }
}

// Static dispatch with generics
fn process_with_static<P: Processor>(processor: &P, data: &str) -> Result<String, ProcessError> {
    processor.process(data)
}

// Dynamic dispatch with trait objects
fn process_with_dynamic(processor: &dyn Processor, data: &str) -> Result<String, ProcessError> {
    processor.process(data)
}

// Factory pattern
fn create_processor(format: &str) -> Option<Box<dyn Processor>> {
    match format {
        "json" => Some(Box::new(JsonProcessor)),
        "xml" => Some(Box::new(XmlProcessor)),
        _ => None,
    }
}
```

### 🔗 Associated Types vs Generics

```rust
// Associated Types: One implementation per type
trait Iterator {
    type Item;  // Each iterator has one specific item type
    fn next(&mut self) -> Option<Self::Item>;
}

struct Counter { current: u32, max: u32 }

impl Iterator for Counter {
    type Item = u32;  // Counter always yields u32

    fn next(&mut self) -> Option<Self::Item> {
        if self.current < self.max {
            let current = self.current;
            self.current += 1;
            Some(current)
        } else {
            None
        }
    }
}

// Generics: Multiple implementations per type
trait From<T> {
    fn from(value: T) -> Self;
}

struct UserId(u32);

impl From<u32> for UserId {
    fn from(value: u32) -> Self { UserId(value) }
}

impl From<String> for UserId {
    fn from(value: String) -> Self {
        UserId(value.parse().unwrap_or(0))
    }
}
```

---

## ⚡ Memory Management Patterns

### 🧠 Stack vs Heap Strategy

```rust
// Prefer stack allocation for small, known-size data
#[derive(Copy, Clone)]
struct Point { x: f32, y: f32 }

#[derive(Copy, Clone)]
struct Color { r: u8, g: u8, b: u8 }

struct Pixel { point: Point, color: Color }  // Stack allocated

// Use heap for large, variable-sized, or shared data
struct Image {
    width: u32,
    height: u32,
    pixels: Vec<Pixel>,  // Heap allocated vector
}

// String slices vs owned strings
fn process_text(text: &str) -> String {  // Accept slice, return owned
    text.to_uppercase()
}

// Cow (Clone on Write) for conditional ownership
use std::borrow::Cow;

fn process_path<'a>(path: &'a str) -> Cow<'a, str> {
    if path.starts_with('/') {
        Cow::Borrowed(path)  // No allocation needed
    } else {
        Cow::Owned(format!("/{}", path))  // Allocate when needed
    }
}
```

### 🔄 Memory Pool Pattern

```rust
use std::sync::{Arc, Mutex};
use std::collections::VecDeque;

pub struct Pool<T> {
    objects: Arc<Mutex<VecDeque<T>>>,
    factory: Box<dyn Fn() -> T + Send + Sync>,
}

impl<T> Pool<T>
where
    T: Send + 'static,
{
    pub fn new<F>(size: usize, factory: F) -> Self
    where
        F: Fn() -> T + Send + Sync + 'static,
    {
        let mut objects = VecDeque::with_capacity(size);
        for _ in 0..size {
            objects.push_back(factory());
        }

        Self {
            objects: Arc::new(Mutex::new(objects)),
            factory: Box::new(factory),
        }
    }

    pub fn get(&self) -> PooledObject<T> {
        let obj = {
            let mut objects = self.objects.lock().unwrap();
            objects.pop_front()
        };

        let obj = obj.unwrap_or_else(|| (self.factory)());
        PooledObject::new(obj, Arc::clone(&self.objects))
    }
}

pub struct PooledObject<T> {
    obj: Option<T>,
    pool: Arc<Mutex<VecDeque<T>>>,
}

impl<T> PooledObject<T> {
    fn new(obj: T, pool: Arc<Mutex<VecDeque<T>>>) -> Self {
        Self { obj: Some(obj), pool }
    }
}

impl<T> Drop for PooledObject<T> {
    fn drop(&mut self) {
        if let Some(obj) = self.obj.take() {
            let mut pool = self.pool.lock().unwrap();
            pool.push_back(obj);
        }
    }
}

impl<T> std::ops::Deref for PooledObject<T> {
    type Target = T;
    fn deref(&self) -> &Self::Target {
        self.obj.as_ref().unwrap()
    }
}

impl<T> std::ops::DerefMut for PooledObject<T> {
    fn deref_mut(&mut self) -> &mut Self::Target {
        self.obj.as_mut().unwrap()
    }
}
```

---

## 🔀 Concurrency & Async

### 🧵 Thread Safety Patterns

```rust
use std::sync::{Arc, Mutex, RwLock, Condvar};
use std::thread;
use std::time::Duration;

// Shared state with Mutex
#[derive(Default)]
struct Counter {
    value: Arc<Mutex<u64>>,
}

impl Counter {
    fn increment(&self) {
        let mut value = self.value.lock().unwrap();
        *value += 1;
    }

    fn get(&self) -> u64 {
        *self.value.lock().unwrap()
    }
}

// Reader-writer lock for read-heavy workloads
struct Cache<K, V> {
    data: RwLock<std::collections::HashMap<K, V>>,
}

impl<K, V> Cache<K, V>
where
    K: Eq + std::hash::Hash + Clone,
    V: Clone,
{
    fn new() -> Self {
        Self { data: RwLock::new(std::collections::HashMap::new()) }
    }

    fn get(&self, key: &K) -> Option<V> {
        self.data.read().unwrap().get(key).cloned()
    }

    fn insert(&self, key: K, value: V) {
        self.data.write().unwrap().insert(key, value);
    }
}

// Channel-based communication
use std::sync::mpsc;

fn worker_pool_example() {
    let (tx, rx) = mpsc::channel();
    let rx = Arc::new(Mutex::new(rx));

    // Spawn worker threads
    for i in 0..4 {
        let rx = Arc::clone(&rx);
        thread::spawn(move || {
            loop {
                let job = {
                    let rx = rx.lock().unwrap();
                    rx.recv()
                };

                match job {
                    Ok(data) => {
                        println!("Worker {} processing: {}", i, data);
                        // Process data
                    },
                    Err(_) => break,  // Channel closed
                }
            }
        });
    }

    // Send work
    for i in 0..10 {
        tx.send(format!("job {}", i)).unwrap();
    }
}
```

### ⚡ Async/Await Patterns

```rust
use tokio::{time, sync::{Semaphore, Mutex}};
use std::sync::Arc;

// Async error handling
#[derive(Debug)]
enum NetworkError {
    Timeout,
    ConnectionFailed,
    InvalidResponse,
}

async fn fetch_with_retry(url: &str, retries: u32) -> Result<String, NetworkError> {
    for attempt in 0..=retries {
        match fetch_data(url).await {
            Ok(data) => return Ok(data),
            Err(NetworkError::Timeout) if attempt < retries => {
                let delay = Duration::from_millis(100 * (1 << attempt));  // Exponential backoff
                time::sleep(delay).await;
                continue;
            },
            Err(e) => return Err(e),
        }
    }
    unreachable!()
}

// Rate limiting with semaphore
struct RateLimiter {
    semaphore: Arc<Semaphore>,
}

impl RateLimiter {
    fn new(limit: usize) -> Self {
        Self {
            semaphore: Arc::new(Semaphore::new(limit)),
        }
    }

    async fn acquire(&self) -> tokio::sync::SemaphorePermit {
        self.semaphore.acquire().await.unwrap()
    }
}

// Concurrent processing with backpressure
async fn process_urls(urls: Vec<String>, concurrency: usize) -> Vec<Result<String, NetworkError>> {
    let limiter = RateLimiter::new(concurrency);
    let tasks = urls.into_iter().map(|url| {
        let limiter = limiter.clone();
        tokio::spawn(async move {
            let _permit = limiter.acquire().await;
            fetch_with_retry(&url, 3).await
        })
    });

    futures::future::join_all(tasks).await
        .into_iter()
        .map(|result| result.unwrap())
        .collect()
}

// Async streams
use futures::stream::{Stream, StreamExt};

fn number_stream() -> impl Stream<Item = i32> {
    futures::stream::iter(0..10)
        .then(|n| async move {
            time::sleep(Duration::from_millis(100)).await;
            n * 2
        })
}

async fn consume_stream() {
    let mut stream = number_stream();
    while let Some(value) = stream.next().await {
        println!("Received: {}", value);
    }
}
```

### 🔄 Actor Model Pattern

```rust
use tokio::sync::{mpsc, oneshot};

// Message types for actor
#[derive(Debug)]
enum ActorMessage {
    GetCount { respond_to: oneshot::Sender<u64> },
    Increment,
    Reset,
    Stop,
}

// Actor state
struct CounterActor {
    count: u64,
    receiver: mpsc::Receiver<ActorMessage>,
}

impl CounterActor {
    fn new() -> (Self, CounterHandle) {
        let (sender, receiver) = mpsc::channel(100);
        let actor = Self { count: 0, receiver };
        let handle = CounterHandle { sender };
        (actor, handle)
    }

    async fn run(mut self) {
        while let Some(msg) = self.receiver.recv().await {
            match msg {
                ActorMessage::GetCount { respond_to } => {
                    let _ = respond_to.send(self.count);
                },
                ActorMessage::Increment => {
                    self.count += 1;
                },
                ActorMessage::Reset => {
                    self.count = 0;
                },
                ActorMessage::Stop => break,
            }
        }
    }
}

// Handle for communicating with actor
#[derive(Clone)]
struct CounterHandle {
    sender: mpsc::Sender<ActorMessage>,
}

impl CounterHandle {
    async fn get_count(&self) -> u64 {
        let (tx, rx) = oneshot::channel();
        self.sender.send(ActorMessage::GetCount { respond_to: tx }).await.unwrap();
        rx.await.unwrap()
    }

    async fn increment(&self) {
        self.sender.send(ActorMessage::Increment).await.unwrap();
    }

    async fn reset(&self) {
        self.sender.send(ActorMessage::Reset).await.unwrap();
    }
}

// Usage
async fn actor_example() {
    let (actor, handle) = CounterActor::new();

    // Spawn actor
    tokio::spawn(actor.run());

    // Use handle
    handle.increment().await;
    handle.increment().await;
    let count = handle.get_count().await;
    println!("Count: {}", count);  // Count: 2
}
```

---

## 📦 Crates & Modules

### 🏗️ Module Organization

```rust
// src/lib.rs - Library root
pub mod config;
pub mod database;
pub mod handlers;
pub mod models;
pub mod utils;

pub use config::Config;
pub use database::Database;

// Re-export commonly used items
pub mod prelude {
    pub use crate::config::Config;
    pub use crate::database::{Database, DatabaseError};
    pub use crate::models::{User, Post};
}

// src/config/mod.rs
mod builder;
mod loader;

pub use builder::ConfigBuilder;
pub use loader::load_from_file;

#[derive(Debug, Clone)]
pub struct Config {
    pub database_url: String,
    pub port: u16,
    pub log_level: String,
}

// src/models/mod.rs
mod user;
mod post;

pub use user::User;
pub use post::Post;

// Feature flags in Cargo.toml
[features]
default = ["json"]
json = ["serde_json"]
yaml = ["serde_yaml"]
database = ["sqlx", "uuid"]
```

### 📋 Cargo.toml Best Practices

```toml
[package]
name = "myapp"
version = "0.1.0"
edition = "2021"
rust-version = "1.70"  # Minimum supported Rust version
license = "MIT OR Apache-2.0"
description = "A sample Rust application"
repository = "https://github.com/user/myapp"
keywords = ["web", "api", "database"]
categories = ["web-programming"]

[dependencies]
# Async runtime
tokio = { version = "1.0", features = ["full"] }

# Serialization
serde = { version = "1.0", features = ["derive"] }
serde_json = { version = "1.0", optional = true }
serde_yaml = { version = "0.9", optional = true }

# Database (optional)
sqlx = { version = "0.7", features = ["runtime-tokio-rustls", "postgres"], optional = true }
uuid = { version = "1.0", features = ["v4", "serde"], optional = true }

# HTTP client/server
reqwest = { version = "0.11", features = ["json"] }
axum = "0.7"

# Logging
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }

# Configuration
clap = { version = "4.0", features = ["derive"] }
config = "0.13"

# Error handling
anyhow = "1.0"
thiserror = "1.0"

[dev-dependencies]
tokio-test = "0.4"
criterion = "0.5"

[features]
default = ["json"]
json = ["serde_json"]
yaml = ["serde_yaml"]
database = ["sqlx", "uuid"]

[[bin]]
name = "server"
path = "src/bin/server.rs"

[[bench]]
name = "processing"
harness = false
```

---

## 🧪 Testing & Benchmarking

### ✅ Comprehensive Testing Strategy

```rust
// Unit tests
#[cfg(test)]
mod tests {
    use super::*;
    use std::time::Duration;

    #[test]
    fn test_basic_functionality() {
        let result = add(2, 3);
        assert_eq!(result, 5);
    }

    #[test]
    fn test_error_conditions() {
        let result = divide(10, 0);
        assert!(result.is_err());
        assert_eq!(result.unwrap_err(), DivisionError::DivideByZero);
    }

    #[test]
    #[should_panic(expected = "overflow")]
    fn test_overflow() {
        let _ = add_unchecked(u32::MAX, 1);
    }

    // Property-based testing with proptest
    use proptest::prelude::*;

    proptest! {
        #[test]
        fn test_reversible_operations(x in 0u32..1000) {
            let encoded = encode(x);
            let decoded = decode(&encoded)?;
            prop_assert_eq!(x, decoded);
        }
    }
}

// Integration tests in tests/ directory
// tests/integration_test.rs
use myapp::prelude::*;

#[tokio::test]
async fn test_full_workflow() {
    let config = Config::builder()
        .host("localhost")
        .port(0)  // Use random port
        .build()
        .unwrap();

    let server = Server::new(config).await.unwrap();
    let client = TestClient::new(server.addr());

    // Test complete user journey
    let response = client.create_user("alice").await.unwrap();
    assert_eq!(response.status(), 201);

    let user = client.get_user("alice").await.unwrap();
    assert_eq!(user.name, "alice");
}

// Async testing
#[tokio::test]
async fn test_concurrent_access() {
    let cache = Arc::new(Cache::new());
    let tasks = (0..100).map(|i| {
        let cache = Arc::clone(&cache);
        tokio::spawn(async move {
            cache.insert(i, format!("value-{}", i)).await;
            cache.get(&i).await
        })
    });

    let results = futures::future::join_all(tasks).await;
    for (i, result) in results.into_iter().enumerate() {
        let value = result.unwrap().unwrap();
        assert_eq!(value, format!("value-{}", i));
    }
}

// Mock testing
#[cfg(test)]
mod mocks {
    use super::*;
    use std::sync::Mutex;

    pub struct MockDatabase {
        calls: Mutex<Vec<String>>,
    }

    impl MockDatabase {
        pub fn new() -> Self {
            Self { calls: Mutex::new(Vec::new()) }
        }

        pub fn get_calls(&self) -> Vec<String> {
            self.calls.lock().unwrap().clone()
        }
    }

    #[async_trait::async_trait]
    impl DatabaseTrait for MockDatabase {
        async fn save_user(&self, user: &User) -> Result<(), DatabaseError> {
            self.calls.lock().unwrap().push(format!("save_user({})", user.id));
            Ok(())
        }
    }

    #[tokio::test]
    async fn test_service_with_mock() {
        let mock_db = Arc::new(MockDatabase::new());
        let service = UserService::new(mock_db.clone());

        service.create_user("alice").await.unwrap();

        let calls = mock_db.get_calls();
        assert!(calls.contains(&"save_user(alice)".to_string()));
    }
}
```

### 📊 Benchmarking with Criterion

```rust
// benches/processing.rs
use criterion::{black_box, criterion_group, criterion_main, Criterion, BenchmarkId};
use myapp::processing::*;

fn bench_algorithms(c: &mut Criterion) {
    let mut group = c.benchmark_group("sorting");

    for size in [100, 1000, 10000].iter() {
        let data: Vec<i32> = (0..*size).collect();

        group.bench_with_input(
            BenchmarkId::new("quicksort", size),
            size,
            |b, &size| {
                b.iter(|| {
                    let mut data = black_box(data.clone());
                    quicksort(&mut data);
                });
            },
        );

        group.bench_with_input(
            BenchmarkId::new("mergesort", size),
            size,
            |b, &size| {
                b.iter(|| {
                    let mut data = black_box(data.clone());
                    mergesort(&mut data);
                });
            },
        );
    }
    group.finish();
}

// Async benchmarking
fn bench_async_operations(c: &mut Criterion) {
    let rt = tokio::runtime::Runtime::new().unwrap();

    c.bench_function("async_fetch", |b| {
        b.to_async(&rt).iter(|| async {
            let result = fetch_data(black_box("http://example.com")).await;
            black_box(result)
        });
    });
}

criterion_group!(benches, bench_algorithms, bench_async_operations);
criterion_main!(benches);
```

---

## 🔧 Error Handling

### 🎯 Error Design Patterns

```rust
use thiserror::Error;
use std::fmt;

// Domain-specific error types
#[derive(Error, Debug)]
pub enum UserError {
    #[error("User not found: {id}")]
    NotFound { id: String },

    #[error("Invalid email format: {email}")]
    InvalidEmail { email: String },

    #[error("User already exists: {email}")]
    AlreadyExists { email: String },

    #[error("Database error")]
    Database(#[from] sqlx::Error),

    #[error("Network error")]
    Network(#[from] reqwest::Error),
}

// Application-wide error type
#[derive(Error, Debug)]
pub enum AppError {
    #[error("User error")]
    User(#[from] UserError),

    #[error("Configuration error: {0}")]
    Config(String),

    #[error("I/O error")]
    Io(#[from] std::io::Error),
}

// Result type aliases
pub type Result<T, E = AppError> = std::result::Result<T, E>;
pub type UserResult<T> = std::result::Result<T, UserError>;

// Error context and chaining
use anyhow::{Context, Result as AnyhowResult};

fn load_config() -> AnyhowResult<Config> {
    let content = std::fs::read_to_string("config.toml")
        .context("Failed to read config file")?;

    let config: Config = toml::from_str(&content)
        .context("Failed to parse config file")?;

    validate_config(&config)
        .context("Config validation failed")?;

    Ok(config)
}

// Custom error with additional context
#[derive(Debug)]
pub struct ProcessingError {
    pub message: String,
    pub operation: String,
    pub input_size: usize,
    pub source: Option<Box<dyn std::error::Error + Send + Sync>>,
}

impl fmt::Display for ProcessingError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "Processing failed: {} (operation: {}, input_size: {})",
               self.message, self.operation, self.input_size)
    }
}

impl std::error::Error for ProcessingError {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        self.source.as_ref().map(|e| e.as_ref() as &dyn std::error::Error)
    }
}

// Error recovery patterns
async fn robust_operation() -> Result<String> {
    // Try primary method
    match primary_operation().await {
        Ok(result) => return Ok(result),
        Err(e) if e.is_retryable() => {
            // Retry with backoff
            for attempt in 1..=3 {
                tokio::time::sleep(Duration::from_millis(100 * attempt)).await;
                if let Ok(result) = primary_operation().await {
                    return Ok(result);
                }
            }
        },
        Err(e) => return Err(e),
    }

    // Fall back to secondary method
    secondary_operation().await
        .context("Both primary and secondary operations failed")
}
```

### 🛡️ Error Handling Best Practices

```rust
// Early returns with ?
fn process_file(path: &Path) -> Result<String> {
    let content = std::fs::read_to_string(path)?;
    let processed = parse_content(&content)?;
    let validated = validate_content(&processed)?;
    Ok(format_output(&validated))
}

// Collecting errors
fn process_multiple_files(paths: &[PathBuf]) -> Result<Vec<String>, Vec<AppError>> {
    let mut results = Vec::new();
    let mut errors = Vec::new();

    for path in paths {
        match process_file(path) {
            Ok(result) => results.push(result),
            Err(e) => errors.push(e),
        }
    }

    if errors.is_empty() {
        Ok(results)
    } else {
        Err(errors)
    }
}

// Option handling patterns
fn safe_division(a: f64, b: f64) -> Option<f64> {
    if b.abs() < f64::EPSILON {
        None
    } else {
        Some(a / b)
    }
}

// Chaining options and results
fn complex_calculation(input: &str) -> Option<f64> {
    input.parse::<f64>().ok()
        .and_then(|x| safe_division(x, 2.0))
        .filter(|&x| x > 0.0)
        .map(|x| x.sqrt())
}
```

---

## 🚀 Performance Optimization

### 📊 Profiling-Driven Optimization

```rust
// Micro-benchmarks for hot paths
#[inline(always)]
fn fast_hash(data: &[u8]) -> u64 {
    // Use a fast non-cryptographic hash for hot paths
    use std::hash::{Hash, Hasher};
    let mut hasher = fxhash::FxHasher::default();
    data.hash(&mut hasher);
    hasher.finish()
}

// Zero-copy string operations
fn process_lines(input: &str) -> impl Iterator<Item = &str> {
    input.lines()
        .filter(|line| !line.trim().is_empty())
        .filter(|line| !line.starts_with('#'))
}

// Efficient collections usage
use std::collections::{HashMap, BTreeMap, VecDeque};
use ahash::AHashMap;  // Faster HashMap alternative

// Choose the right collection
fn choose_collection() {
    // Fast lookups, good for general use
    let fast_map: AHashMap<String, i32> = AHashMap::new();

    // Ordered iteration needed
    let ordered_map: BTreeMap<String, i32> = BTreeMap::new();

    // FIFO queue operations
    let queue: VecDeque<String> = VecDeque::new();

    // Pre-allocate when size is known
    let mut vec = Vec::with_capacity(1000);
}

// Memory layout optimization
#[repr(C)]  // Predictable layout
struct OptimizedStruct {
    // Order fields by size (largest first) to minimize padding
    large_field: u64,    // 8 bytes
    medium_field: u32,   // 4 bytes
    small_field: u16,    // 2 bytes
    tiny_field: u8,      // 1 byte
    // Compiler adds 1 byte padding here
}

// SIMD operations
#[cfg(target_arch = "x86_64")]
fn simd_sum(data: &[f32]) -> f32 {
    if is_x86_feature_detected!("avx2") {
        unsafe { simd_sum_avx2(data) }
    } else if is_x86_feature_detected!("sse2") {
        unsafe { simd_sum_sse2(data) }
    } else {
        data.iter().sum()
    }
}

// Branch prediction optimization
fn optimized_search(data: &[i32], target: i32) -> Option<usize> {
    // Likely branch first
    if likely(data.len() < 1000) {
        // Linear search for small arrays
        data.iter().position(|&x| x == target)
    } else {
        // Binary search for large arrays (assuming sorted)
        data.binary_search(&target).ok()
    }
}

// Likely/unlikely hints (requires nightly or external crate)
#[inline(always)]
const fn likely(b: bool) -> bool {
    std::intrinsics::likely(b)
}

// Memory prefetching for predictable access patterns
use std::arch::x86_64::_mm_prefetch;

fn prefetch_optimization(data: &mut [u64]) {
    for i in 0..data.len() {
        // Prefetch next cache line while processing current
        if i + 8 < data.len() {
            unsafe {
                _mm_prefetch(
                    data.as_ptr().add(i + 8) as *const i8,
                    std::arch::x86_64::_MM_HINT_T0
                );
            }
        }

        // Process current element
        data[i] = data[i].wrapping_mul(1664525).wrapping_add(1013904223);
    }
}
```

### 🔧 Allocation Optimization

```rust
// Custom allocators
use bumpalo::Bump;

// Arena allocation for temporary data
fn process_batch(items: &[String]) -> Vec<String> {
    let arena = Bump::new();
    let temp_results: Vec<_> = items.iter()
        .map(|item| {
            // Use arena for temporary allocations
            let temp_str = arena.alloc_str(&item.to_uppercase());
            process_string(temp_str)
        })
        .collect();

    // Arena is dropped here, freeing all temporary allocations
    temp_results
}

// String interning for deduplication
use string_cache::DefaultAtom as Atom;

struct InternedStrings {
    atoms: HashMap<String, Atom>,
}

impl InternedStrings {
    fn intern(&mut self, s: String) -> Atom {
        *self.atoms.entry(s.clone()).or_insert_with(|| Atom::from(s))
    }
}

// Object pooling
pub struct BufferPool {
    pool: Arc<Mutex<Vec<Vec<u8>>>>,
    default_capacity: usize,
}

impl BufferPool {
    pub fn new(default_capacity: usize) -> Self {
        Self {
            pool: Arc::new(Mutex::new(Vec::new())),
            default_capacity,
        }
    }

    pub fn get(&self) -> PooledBuffer {
        let buffer = {
            let mut pool = self.pool.lock().unwrap();
            pool.pop().unwrap_or_else(|| Vec::with_capacity(self.default_capacity))
        };

        PooledBuffer {
            buffer: Some(buffer),
            pool: Arc::clone(&self.pool),
        }
    }
}

pub struct PooledBuffer {
    buffer: Option<Vec<u8>>,
    pool: Arc<Mutex<Vec<Vec<u8>>>>,
}

impl Drop for PooledBuffer {
    fn drop(&mut self) {
        if let Some(mut buffer) = self.buffer.take() {
            buffer.clear();  // Retain capacity, clear data
            self.pool.lock().unwrap().push(buffer);
        }
    }
}

impl std::ops::Deref for PooledBuffer {
    type Target = Vec<u8>;
    fn deref(&self) -> &Self::Target {
        self.buffer.as_ref().unwrap()
    }
}

impl std::ops::DerefMut for PooledBuffer {
    fn deref_mut(&mut self) -> &mut Self::Target {
        self.buffer.as_mut().unwrap()
    }
}
```

---

## 🏗️ API Design Patterns

### 🎯 Builder Pattern Advanced

```rust
// Typestate builder - prevents invalid configurations at compile time
pub struct ConfigBuilder<State = Initial> {
    inner: PartialConfig,
    _state: std::marker::PhantomData<State>,
}

pub struct Initial;
pub struct HasHost;
pub struct Complete;

#[derive(Default)]
struct PartialConfig {
    host: Option<String>,
    port: Option<u16>,
    timeout: Option<Duration>,
    tls: bool,
}

impl ConfigBuilder<Initial> {
    pub fn new() -> Self {
        Self {
            inner: PartialConfig::default(),
            _state: std::marker::PhantomData,
        }
    }
}

impl<State> ConfigBuilder<State> {
    pub fn host(mut self, host: String) -> ConfigBuilder<HasHost> {
        self.inner.host = Some(host);
        ConfigBuilder {
            inner: self.inner,
            _state: std::marker::PhantomData,
        }
    }

    pub fn port(mut self, port: u16) -> Self {
        self.inner.port = Some(port);
        self
    }

    pub fn timeout(mut self, timeout: Duration) -> Self {
        self.inner.timeout = Some(timeout);
        self
    }

    pub fn enable_tls(mut self) -> Self {
        self.inner.tls = true;
        self
    }
}

impl ConfigBuilder<HasHost> {
    pub fn build(self) -> Config {
        Config {
            host: self.inner.host.unwrap(),  // Safe: guaranteed by type system
            port: self.inner.port.unwrap_or(8080),
            timeout: self.inner.timeout.unwrap_or(Duration::from_secs(30)),
            tls: self.inner.tls,
        }
    }
}

// Usage - won't compile without required host
let config = ConfigBuilder::new()
    .host("example.com".to_string())  // Required!
    .port(443)
    .enable_tls()
    .build();  // Only available after host is set
```

### 🔧 Extension Trait Pattern

```rust
// Extending existing types with custom functionality
pub trait StringExt {
    fn truncate_ellipsis(&self, max_len: usize) -> String;
    fn is_email(&self) -> bool;
    fn to_snake_case(&self) -> String;
}

impl StringExt for str {
    fn truncate_ellipsis(&self, max_len: usize) -> String {
        if self.len() <= max_len {
            self.to_string()
        } else {
            format!("{}...", &self[..max_len.saturating_sub(3)])
        }
    }

    fn is_email(&self) -> bool {
        self.contains('@') && self.contains('.') // Simplified validation
    }

    fn to_snake_case(&self) -> String {
        let mut result = String::new();
        for (i, ch) in self.chars().enumerate() {
            if ch.is_uppercase() && i > 0 {
                result.push('_');
            }
            result.extend(ch.to_lowercase());
        }
        result
    }
}

// Usage
let text = "Hello World";
let truncated = text.truncate_ellipsis(8);  // "Hello..."
let snake = "CamelCase".to_snake_case();    // "camel_case"
```

### 🎭 Newtype Pattern

```rust
// Strong typing with newtypes
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct UserId(uuid::Uuid);

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Email(String);

#[derive(Debug, Clone, Copy, PartialEq, PartialOrd)]
pub struct Timestamp(i64);

impl UserId {
    pub fn new() -> Self {
        Self(uuid::Uuid::new_v4())
    }

    pub fn from_str(s: &str) -> Result<Self, uuid::Error> {
        Ok(Self(uuid::Uuid::parse_str(s)?))
    }
}

impl Email {
    pub fn new(email: String) -> Result<Self, ValidationError> {
        if email.contains('@') && email.contains('.') {
            Ok(Self(email))
        } else {
            Err(ValidationError::InvalidEmail)
        }
    }

    pub fn domain(&self) -> &str {
        self.0.split('@').nth(1).unwrap_or("")
    }
}

impl Timestamp {
    pub fn now() -> Self {
        use std::time::{SystemTime, UNIX_EPOCH};
        let duration = SystemTime::now().duration_since(UNIX_EPOCH).unwrap();
        Self(duration.as_secs() as i64)
    }

    pub fn as_secs(&self) -> i64 {
        self.0
    }
}

// Deriving common traits
impl std::fmt::Display for UserId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

// Serde support
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
struct User {
    id: UserId,
    email: Email,
    created_at: Timestamp,
}
```

---

## 🔒 Unsafe Rust

### ⚠️ Safe Abstractions Over Unsafe Code

```rust
// Raw pointer manipulation with safety invariants
pub struct RingBuffer<T> {
    data: *mut T,
    capacity: usize,
    head: usize,
    tail: usize,
    len: usize,
}

impl<T> RingBuffer<T> {
    pub fn new(capacity: usize) -> Self {
        assert!(capacity > 0, "Capacity must be greater than 0");

        let layout = std::alloc::Layout::array::<T>(capacity).unwrap();
        let data = unsafe {
            let ptr = std::alloc::alloc(layout) as *mut T;
            if ptr.is_null() {
                std::alloc::handle_alloc_error(layout);
            }
            ptr
        };

        Self {
            data,
            capacity,
            head: 0,
            tail: 0,
            len: 0,
        }
    }

    pub fn push(&mut self, item: T) -> Result<(), T> {
        if self.len == self.capacity {
            return Err(item);  // Buffer full
        }

        unsafe {
            // Safe: we've checked bounds and ensured capacity > 0
            std::ptr::write(self.data.add(self.tail), item);
        }

        self.tail = (self.tail + 1) % self.capacity;
        self.len += 1;
        Ok(())
    }

    pub fn pop(&mut self) -> Option<T> {
        if self.len == 0 {
            return None;
        }

        let item = unsafe {
            // Safe: we've checked that len > 0
            std::ptr::read(self.data.add(self.head))
        };

        self.head = (self.head + 1) % self.capacity;
        self.len -= 1;
        Some(item)
    }

    pub fn len(&self) -> usize {
        self.len
    }

    pub fn is_empty(&self) -> bool {
        self.len == 0
    }
}

unsafe impl<T: Send> Send for RingBuffer<T> {}
unsafe impl<T: Sync> Sync for RingBuffer<T> {}

impl<T> Drop for RingBuffer<T> {
    fn drop(&mut self) {
        // Drop all remaining elements
        while self.pop().is_some() {}

        // Deallocate memory
        unsafe {
            let layout = std::alloc::Layout::array::<T>(self.capacity).unwrap();
            std::alloc::dealloc(self.data as *mut u8, layout);
        }
    }
}

// FFI bindings with safe wrappers
extern "C" {
    fn c_function(data: *const u8, len: size_t) -> c_int;
    fn c_allocate(size: size_t) -> *mut u8;
    fn c_free(ptr: *mut u8);
}

// Safe wrapper
pub fn call_c_function(data: &[u8]) -> Result<i32, CError> {
    let result = unsafe {
        // Safe: we're passing valid pointer and length
        c_function(data.as_ptr(), data.len())
    };

    if result < 0 {
        Err(CError::from_code(result))
    } else {
        Ok(result)
    }
}

// RAII wrapper for C resources
pub struct CBuffer {
    ptr: *mut u8,
    len: usize,
}

impl CBuffer {
    pub fn new(size: usize) -> Option<Self> {
        let ptr = unsafe { c_allocate(size) };
        if ptr.is_null() {
            None
        } else {
            Some(Self { ptr, len: size })
        }
    }

    pub fn as_slice(&self) -> &[u8] {
        unsafe {
            std::slice::from_raw_parts(self.ptr, self.len)
        }
    }

    pub fn as_mut_slice(&mut self) -> &mut [u8] {
        unsafe {
            std::slice::from_raw_parts_mut(self.ptr, self.len)
        }
    }
}

impl Drop for CBuffer {
    fn drop(&mut self) {
        unsafe {
            c_free(self.ptr);
        }
    }
}
```

### 🛡️ Unsafe Guidelines

```rust
// Document safety invariants
/// # Safety
///
/// This function assumes:
/// - `ptr` is a valid pointer to at least `len` bytes of memory
/// - The memory pointed to by `ptr` is properly aligned for type `T`
/// - The caller has exclusive access to the memory for the duration of this call
unsafe fn process_memory<T>(ptr: *mut T, len: usize) {
    // Implementation that upholds these invariants
}

// Use debug assertions to check invariants
fn safe_wrapper(data: &mut [i32]) {
    debug_assert!(!data.is_empty(), "Data slice must not be empty");
    debug_assert!(data.as_ptr().is_aligned(), "Data must be properly aligned");

    unsafe {
        process_memory(data.as_mut_ptr(), data.len());
    }
}

// Minimize unsafe blocks
fn mixed_safe_unsafe() {
    let data = vec![1, 2, 3, 4, 5];

    // Safe operations
    let len = data.len();
    let sum: i32 = data.iter().sum();

    // Unsafe block minimized to necessary operations only
    let raw_sum = unsafe {
        let ptr = data.as_ptr();
        let mut total = 0;
        for i in 0..len {
            total += *ptr.add(i);  // Unsafe pointer arithmetic
        }
        total
    };

    // More safe operations
    assert_eq!(sum, raw_sum);
}
```

---

## 📡 Network & I/O

### 🌐 HTTP Client/Server Patterns

```rust
use reqwest::{Client, ClientBuilder};
use axum::{Router, routing::get, response::Json, extract::Query};
use tower::ServiceBuilder;
use tower_http::{trace::TraceLayer, cors::CorsLayer};

// HTTP Client with connection pooling and middleware
#[derive(Clone)]
pub struct HttpClient {
    client: Client,
}

impl HttpClient {
    pub fn new() -> Result<Self, reqwest::Error> {
        let client = ClientBuilder::new()
            .timeout(Duration::from_secs(30))
            .pool_idle_timeout(Duration::from_secs(90))
            .pool_max_idle_per_host(10)
            .user_agent("myapp/1.0")
            .build()?;

        Ok(Self { client })
    }

    pub async fn get_json<T>(&self, url: &str) -> Result<T, ApiError>
    where
        T: serde::de::DeserializeOwned,
    {
        let response = self.client
            .get(url)
            .header("Accept", "application/json")
            .send()
            .await?;

        if !response.status().is_success() {
            return Err(ApiError::HttpError(response.status()));
        }

        let data = response.json().await?;
        Ok(data)
    }

    pub async fn post_json<T, R>(&self, url: &str, data: &T) -> Result<R, ApiError>
    where
        T: serde::Serialize,
        R: serde::de::DeserializeOwned,
    {
        let response = self.client
            .post(url)
            .header("Content-Type", "application/json")
            .json(data)
            .send()
            .await?;

        response.json().await.map_err(Into::into)
    }
}

// HTTP Server with middleware
pub async fn create_server() -> Router {
    Router::new()
        .route("/health", get(health_check))
        .route("/users", get(list_users).post(create_user))
        .route("/users/:id", get(get_user).put(update_user))
        .layer(
            ServiceBuilder::new()
                .layer(TraceLayer::new_for_http())
                .layer(CorsLayer::permissive())
                .into_inner()
        )
}

async fn health_check() -> Json<serde_json::Value> {
    Json(serde_json::json!({
        "status": "healthy",
        "timestamp": chrono::Utc::now().to_rfc3339()
    }))
}

// Request/response types
#[derive(Serialize, Deserialize)]
struct CreateUserRequest {
    name: String,
    email: String,
}

#[derive(Serialize, Deserialize)]
struct UserResponse {
    id: UserId,
    name: String,
    email: String,
    created_at: chrono::DateTime<chrono::Utc>,
}

async fn create_user(
    Json(req): Json<CreateUserRequest>
) -> Result<Json<UserResponse>, AppError> {
    // Validate request
    let email = Email::new(req.email)?;

    // Create user
    let user = User::new(req.name, email);

    // Save to database (example)
    // db.save_user(&user).await?;

    Ok(Json(UserResponse {
        id: user.id,
        name: user.name,
        email: user.email.to_string(),
        created_at: user.created_at,
    }))
}
```

### 📊 WebSocket Real-time Communication

```rust
use tokio_tungstenite::{WebSocketStream, tungstenite::Message};
use futures_util::{SinkExt, StreamExt};
use tokio::sync::{mpsc, broadcast};

pub struct WebSocketHandler {
    connections: Arc<Mutex<HashMap<String, mpsc::UnboundedSender<Message>>>>,
    broadcast_tx: broadcast::Sender<BroadcastMessage>,
}

#[derive(Clone, Debug)]
pub struct BroadcastMessage {
    pub from: Option<String>,
    pub content: String,
    pub message_type: MessageType,
}

#[derive(Clone, Debug)]
pub enum MessageType {
    Chat,
    System,
    Notification,
}

impl WebSocketHandler {
    pub fn new() -> Self {
        let (broadcast_tx, _) = broadcast::channel(1000);

        Self {
            connections: Arc::new(Mutex::new(HashMap::new())),
            broadcast_tx,
        }
    }

    pub async fn handle_connection(
        &self,
        websocket: WebSocketStream<impl tokio::io::AsyncRead + tokio::io::AsyncWrite + Unpin>,
        client_id: String,
    ) -> Result<(), Box<dyn std::error::Error>> {
        let (mut ws_sender, mut ws_receiver) = websocket.split();
        let (tx, mut rx) = mpsc::unbounded_channel();

        // Register connection
        {
            let mut connections = self.connections.lock().await;
            connections.insert(client_id.clone(), tx);
        }

        // Subscribe to broadcasts
        let mut broadcast_rx = self.broadcast_tx.subscribe();

        // Handle outgoing messages
        let connections = Arc::clone(&self.connections);
        let client_id_for_cleanup = client_id.clone();
        tokio::spawn(async move {
            loop {
                tokio::select! {
                    // Direct messages to this client
                    Some(msg) = rx.recv() => {
                        if ws_sender.send(msg).await.is_err() {
                            break;
                        }
                    },
                    // Broadcast messages
                    Ok(broadcast_msg) = broadcast_rx.recv() => {
                        // Don't send back to sender
                        if broadcast_msg.from.as_ref() != Some(&client_id) {
                            let msg = Message::Text(serde_json::to_string(&broadcast_msg).unwrap());
                            if ws_sender.send(msg).await.is_err() {
                                break;
                            }
                        }
                    },
                    else => break,
                }
            }

            // Cleanup
            connections.lock().await.remove(&client_id_for_cleanup);
        });

        // Handle incoming messages
        while let Some(msg) = ws_receiver.next().await {
            match msg? {
                Message::Text(text) => {
                    if let Ok(broadcast_msg) = self.parse_message(&text, &client_id) {
                        let _ = self.broadcast_tx.send(broadcast_msg);
                    }
                },
                Message::Close(_) => break,
                _ => {}
            }
        }

        Ok(())
    }

    fn parse_message(&self, text: &str, from: &str) -> Result<BroadcastMessage, serde_json::Error> {
        #[derive(Deserialize)]
        struct IncomingMessage {
            content: String,
            #[serde(rename = "type")]
            message_type: Option<String>,
        }

        let incoming: IncomingMessage = serde_json::from_str(text)?;
        let message_type = match incoming.message_type.as_deref() {
            Some("system") => MessageType::System,
            Some("notification") => MessageType::Notification,
            _ => MessageType::Chat,
        };

        Ok(BroadcastMessage {
            from: Some(from.to_string()),
            content: incoming.content,
            message_type,
        })
    }
}
```

### 💾 Database Integration

```rust
use sqlx::{PgPool, Row};

#[derive(Debug, Clone)]
pub struct Database {
    pool: PgPool,
}

impl Database {
    pub async fn new(database_url: &str) -> Result<Self, sqlx::Error> {
        let pool = PgPool::connect(database_url).await?;

        // Run migrations
        sqlx::migrate!("./migrations").run(&pool).await?;

        Ok(Self { pool })
    }

    pub async fn save_user(&self, user: &User) -> Result<(), DatabaseError> {
        sqlx::query!(
            r#"
            INSERT INTO users (id, name, email, created_at)
            VALUES ($1, $2, $3, $4)
            ON CONFLICT (id) DO UPDATE SET
                name = EXCLUDED.name,
                email = EXCLUDED.email
            "#,
            user.id.to_string(),
            user.name,
            user.email.to_string(),
            user.created_at
        )
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    pub async fn get_user(&self, id: &UserId) -> Result<Option<User>, DatabaseError> {
        let row = sqlx::query!(
            "SELECT id, name, email, created_at FROM users WHERE id = $1",
            id.to_string()
        )
        .fetch_optional(&self.pool)
        .await?;

        match row {
            Some(row) => {
                let user = User {
                    id: UserId::from_str(&row.id)?,
                    name: row.name,
                    email: Email::new(row.email)?,
                    created_at: row.created_at,
                };
                Ok(Some(user))
            },
            None => Ok(None),
        }
    }

    // Transaction example
    pub async fn transfer_credits(
        &self,
        from: &UserId,
        to: &UserId,
        amount: u32
    ) -> Result<(), DatabaseError> {
        let mut tx = self.pool.begin().await?;

        // Check balance
        let balance: Option<i32> = sqlx::query_scalar(
            "SELECT credits FROM users WHERE id = $1"
        )
        .bind(from.to_string())
        .fetch_optional(&mut *tx)
        .await?;

        let balance = balance.ok_or(DatabaseError::UserNotFound)?;
        if balance < amount as i32 {
            return Err(DatabaseError::InsufficientFunds);
        }

        // Perform transfer
        sqlx::query!(
            "UPDATE users SET credits = credits - $1 WHERE id = $2",
            amount as i32,
            from.to_string()
        )
        .execute(&mut *tx)
        .await?;

        sqlx::query!(
            "UPDATE users SET credits = credits + $1 WHERE id = $2",
            amount as i32,
            to.to_string()
        )
        .execute(&mut *tx)
        .await?;

        tx.commit().await?;
        Ok(())
    }
}

// Connection pool configuration
pub fn create_pool(database_url: &str) -> Result<PgPool, sqlx::Error> {
    PgPool::connect_with(
        database_url.parse::<sqlx::postgres::PgConnectOptions>()?
            .max_connections(20)
            .min_connections(5)
            .acquire_timeout(Duration::from_secs(8))
            .idle_timeout(Duration::from_secs(8))
    )
}
```

---

## 🛠️ Build System & Cargo

### 📦 Advanced Cargo Configuration

```toml
# Cargo.toml - Production configuration
[package]
name = "production-app"
version = "1.0.0"
edition = "2021"
rust-version = "1.70.0"
description = "A production-ready Rust application"
license = "MIT OR Apache-2.0"
repository = "https://github.com/company/production-app"
documentation = "https://docs.rs/production-app"
readme = "README.md"
keywords = ["web", "api", "database", "microservice"]
categories = ["web-programming", "database"]
authors = ["Your Name <you@company.com>"]
exclude = [
    "tests/fixtures/*",
    "benches/data/*",
    "docs/internal/*",
    ".github/*"
]

[workspace]
members = [
    "crates/core",
    "crates/api",
    "crates/database",
    "crates/shared"
]
resolver = "2"

[dependencies]
# Async runtime
tokio = { version = "1.0", features = ["full"] }

# Web framework
axum = { version = "0.7", features = ["macros"] }
tower = { version = "0.4", features = ["full"] }
tower-http = { version = "0.5", features = ["trace", "cors", "compression-gzip"] }

# Serialization
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"

# Database
sqlx = { version = "0.7", features = ["runtime-tokio-rustls", "postgres", "chrono", "uuid"] }

# HTTP client
reqwest = { version = "0.11", features = ["json", "rustls-tls"], default-features = false }

# Logging and tracing
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter", "json"] }

# Error handling
anyhow = "1.0"
thiserror = "1.0"

# Configuration
config = "0.13"
clap = { version = "4.0", features = ["derive", "env"] }

# Cryptography
argon2 = "0.5"
rand = "0.8"

# Time handling
chrono = { version = "0.4", features = ["serde"] }

# UUID
uuid = { version = "1.0", features = ["v4", "serde"] }

# Development dependencies
[dev-dependencies]
tokio-test = "0.4"
criterion = { version = "0.5", features = ["html_reports"] }
proptest = "1.0"
tempfile = "3.0"

# Build dependencies
[build-dependencies]
anyhow = "1.0"

# Feature flags
[features]
default = ["postgres", "redis"]
postgres = ["sqlx/postgres"]
mysql = ["sqlx/mysql"]
sqlite = ["sqlx/sqlite"]
redis = ["redis"]
metrics = ["metrics", "metrics-prometheus"]

# Performance profiles
[profile.release]
opt-level = 3
lto = true
codegen-units = 1
panic = "abort"
strip = true

[profile.dev]
opt-level = 0
debug = true
incremental = true

[profile.test]
opt-level = 1
debug = true

# Benchmarking profile
[profile.bench]
opt-level = 3
debug = false
rpath = false
lto = true
incremental = false
codegen-units = 1

# Binary configurations
[[bin]]
name = "server"
path = "src/bin/server.rs"

[[bin]]
name = "migrate"
path = "src/bin/migrate.rs"

[[bin]]
name = "worker"
path = "src/bin/worker.rs"

# Library configuration
[lib]
name = "production_app"
path = "src/lib.rs"

# Benchmark configuration
[[bench]]
name = "processing"
harness = false

# Example configuration
[[example]]
name = "basic_usage"
path = "examples/basic_usage.rs"

# Workspace configuration
[workspace.dependencies]
serde = { version = "1.0", features = ["derive"] }
tokio = { version = "1.0", features = ["full"] }
anyhow = "1.0"
thiserror = "1.0"

# Metadata
[package.metadata.docs.rs]
all-features = true
rustdoc-args = ["--cfg", "docsrs"]
```

### 🔧 Build Scripts and Custom Commands

```rust
// build.rs - Build script for code generation
use std::env;
use std::path::Path;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Environment variables
    let out_dir = env::var("OUT_DIR")?;
    let target = env::var("TARGET")?;

    // Generate version info
    generate_version_info(&out_dir)?;

    // Platform-specific compilation
    if target.contains("linux") {
        println!("cargo:rustc-cfg=target_os=\"linux\"");
        link_linux_libs();
    }

    // Proto compilation (if using protobuf)
    #[cfg(feature = "protobuf")]
    compile_protos(&out_dir)?;

    // Rerun if these files change
    println!("cargo:rerun-if-changed=build.rs");
    println!("cargo:rerun-if-changed=proto/");
    println!("cargo:rerun-if-env-changed=DATABASE_URL");

    Ok(())
}

fn generate_version_info(out_dir: &str) -> Result<(), Box<dyn std::error::Error>> {
    let version_file = Path::new(out_dir).join("version.rs");
    let git_hash = std::process::Command::new("git")
        .args(&["rev-parse", "HEAD"])
        .output()
        .map(|output| String::from_utf8_lossy(&output.stdout).trim().to_string())
        .unwrap_or_else(|_| "unknown".to_string());

    let content = format!(
        r#"
        pub const VERSION: &str = "{}";
        pub const GIT_HASH: &str = "{}";
        pub const BUILD_TIME: &str = "{}";
        "#,
        env!("CARGO_PKG_VERSION"),
        git_hash,
        chrono::Utc::now().format("%Y-%m-%d %H:%M:%S UTC")
    );

    std::fs::write(version_file, content)?;
    Ok(())
}

fn link_linux_libs() {
    println!("cargo:rustc-link-lib=ssl");
    println!("cargo:rustc-link-lib=crypto");
}

#[cfg(feature = "protobuf")]
fn compile_protos(out_dir: &str) -> Result<(), Box<dyn std::error::Error>> {
    let proto_files = ["proto/api.proto", "proto/events.proto"];

    prost_build::Config::new()
        .out_dir(out_dir)
        .compile_protos(&proto_files, &["proto/"])?;

    Ok(())
}
```

### 🚀 Cross-compilation and Deployment

```bash
# .cargo/config.toml - Cross-compilation configuration
[target.x86_64-unknown-linux-musl]
linker = "x86_64-linux-musl-gcc"

[target.aarch64-unknown-linux-musl]
linker = "aarch64-linux-musl-gcc"

[env]
RUSTFLAGS = "-C target-cpu=native"

# Alias for common commands
[alias]
b = "build"
c = "check"
t = "test"
r = "run"
rr = "run --release"
```

```dockerfile
# Multi-stage Docker build
FROM rust:1.70-alpine AS builder

# Install build dependencies
RUN apk add --no-cache musl-dev openssl-dev

WORKDIR /app

# Copy manifests
COPY Cargo.toml Cargo.lock ./
COPY crates/*/Cargo.toml ./crates/*/

# Build dependencies (cached layer)
RUN mkdir src && echo "fn main() {}" > src/main.rs && cargo build --release && rm -rf src

# Copy source code
COPY . .

# Build application
RUN touch src/main.rs && cargo build --release --bin server

# Runtime stage
FROM alpine:latest

RUN apk add --no-cache ca-certificates

WORKDIR /app

# Copy binary from builder stage
COPY --from=builder /app/target/release/server ./

# Create non-root user
RUN adduser -D -s /bin/sh appuser
USER appuser

EXPOSE 8080

CMD ["./server"]
```

---

## 🐛 Debugging & Profiling

### 🔍 Advanced Debugging Techniques

```rust
// Debugging macros and utilities
macro_rules! debug_println {
    ($($arg:tt)*) => {
        #[cfg(debug_assertions)]
        println!($($arg)*);
    };
}

macro_rules! trace_fn {
    () => {
        #[cfg(debug_assertions)]
        println!("Entering function: {}", std::any::type_name::<fn()>());
    };
}

// Custom debug formatting
#[derive(Debug)]
struct DebugWrapper<T>(T);

impl<T> std::fmt::Display for DebugWrapper<T>
where
    T: std::fmt::Debug,
{
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{:?}", self.0)
    }
}

// Memory debugging
#[cfg(debug_assertions)]
pub struct MemoryTracker {
    allocations: std::sync::Mutex<std::collections::HashMap<usize, usize>>,
}

#[cfg(debug_assertions)]
impl MemoryTracker {
    pub fn new() -> Self {
        Self {
            allocations: std::sync::Mutex::new(std::collections::HashMap::new()),
        }
    }

    pub fn track_allocation(&self, ptr: usize, size: usize) {
        self.allocations.lock().unwrap().insert(ptr, size);
    }

    pub fn track_deallocation(&self, ptr: usize) {
        self.allocations.lock().unwrap().remove(&ptr);
    }

    pub fn report(&self) {
        let allocations = self.allocations.lock().unwrap();
        let total_size: usize = allocations.values().sum();
        println!("Active allocations: {}, Total size: {} bytes",
                allocations.len(), total_size);
    }
}

// Structured logging for debugging
use tracing::{instrument, debug, info, warn, error};

#[instrument]
async fn process_request(request_id: &str, data: &[u8]) -> Result<String, ProcessError> {
    info!(request_id, data_len = data.len(), "Processing request");

    let start = std::time::Instant::now();

    // Processing logic
    let result = match validate_data(data) {
        Ok(_) => {
            debug!("Data validation passed");
            transform_data(data).await
        },
        Err(e) => {
            warn!(error = %e, "Data validation failed");
            return Err(ProcessError::ValidationFailed(e));
        }
    };

    let duration = start.elapsed();
    info!(request_id, duration_ms = duration.as_millis(), "Request completed");

    result
}

// Performance timing
pub struct Timer {
    name: String,
    start: std::time::Instant,
}

impl Timer {
    pub fn new(name: impl Into<String>) -> Self {
        Self {
            name: name.into(),
            start: std::time::Instant::now(),
        }
    }
}

impl Drop for Timer {
    fn drop(&mut self) {
        let duration = self.start.elapsed();
        println!("{}: {:?}", self.name, duration);
    }
}

// Usage
fn timed_operation() {
    let _timer = Timer::new("expensive_operation");
    // Operation code here
} // Timer prints duration when dropped
```

### 📊 Performance Profiling

```rust
// CPU profiling setup
#[cfg(feature = "profiling")]
pub fn start_profiling() {
    use pprof::ProfilerGuard;

    let guard = pprof::ProfilerGuardBuilder::default()
        .frequency(1000)  // 1000 Hz
        .blocklist(&["libc", "libgcc", "pthread", "vdso"])
        .build()
        .unwrap();

    // Store guard somewhere it won't be dropped
    std::mem::forget(guard);
}

// Memory profiling
#[global_allocator]
#[cfg(feature = "jemalloc")]
static ALLOC: jemallocator::Jemalloc = jemallocator::Jemalloc;

// Custom allocator with tracking
#[cfg(debug_assertions)]
pub struct TrackingAllocator<A: std::alloc::GlobalAlloc> {
    inner: A,
    tracker: &'static MemoryTracker,
}

#[cfg(debug_assertions)]
unsafe impl<A: std::alloc::GlobalAlloc> std::alloc::GlobalAlloc for TrackingAllocator<A> {
    unsafe fn alloc(&self, layout: std::alloc::Layout) -> *mut u8 {
        let ptr = self.inner.alloc(layout);
        if !ptr.is_null() {
            self.tracker.track_allocation(ptr as usize, layout.size());
        }
        ptr
    }

    unsafe fn dealloc(&self, ptr: *mut u8, layout: std::alloc::Layout) {
        self.tracker.track_deallocation(ptr as usize);
        self.inner.dealloc(ptr, layout);
    }
}

// Async profiling
pub struct AsyncProfiler {
    start_time: std::time::Instant,
    samples: std::sync::Mutex<Vec<(String, std::time::Duration)>>,
}

impl AsyncProfiler {
    pub fn new() -> Self {
        Self {
            start_time: std::time::Instant::now(),
            samples: std::sync::Mutex::new(Vec::new()),
        }
    }

    pub fn sample(&self, name: impl Into<String>) {
        let elapsed = self.start_time.elapsed();
        self.samples.lock().unwrap().push((name.into(), elapsed));
    }

    pub fn report(&self) {
        let samples = self.samples.lock().unwrap();
        for (name, duration) in samples.iter() {
            println!("{}: {:?}", name, duration);
        }
    }
}

// Flamegraph integration
#[cfg(feature = "flamegraph")]
pub fn generate_flamegraph() -> Result<(), Box<dyn std::error::Error>> {
    use std::process::Command;

    // Run application with perf
    let mut child = Command::new("perf")
        .args(&["record", "-g", "./target/release/myapp"])
        .spawn()?;

    child.wait()?;

    // Generate flamegraph
    Command::new("perf")
        .args(&["script"])
        .stdout(std::process::Stdio::piped())
        .spawn()?
        .stdout
        .ok_or("Failed to get perf output")?;

    // Process with flamegraph tool
    // (implementation depends on flamegraph tool)

    Ok(())
}
```

---

## 🌍 Real-World Patterns

### 🏗️ Application Architecture

```rust
// Domain-driven design structure
pub mod domain {
    pub mod user {
        pub use self::model::*;
        pub use self::repository::*;
        pub use self::service::*;

        mod model;
        mod repository;
        mod service;
    }

    pub mod shared {
        pub use self::value_objects::*;
        pub use self::events::*;

        mod value_objects;
        mod events;
    }
}

pub mod infrastructure {
    pub mod database;
    pub mod http_client;
    pub mod message_queue;
    pub mod cache;
}

pub mod application {
    pub mod handlers;
    pub mod use_cases;
    pub mod dto;
}

// Dependency injection container
pub struct Container {
    database: Arc<dyn UserRepository>,
    cache: Arc<dyn Cache>,
    event_bus: Arc<dyn EventBus>,
}

impl Container {
    pub fn new(config: &Config) -> Result<Self, Box<dyn std::error::Error>> {
        let database = Arc::new(PostgresUserRepository::new(&config.database_url)?);
        let cache = Arc::new(RedisCache::new(&config.redis_url)?);
        let event_bus = Arc::new(InMemoryEventBus::new());

        Ok(Self { database, cache, event_bus })
    }

    pub fn user_service(&self) -> UserService {
        UserService::new(
            Arc::clone(&self.database),
            Arc::clone(&self.cache),
            Arc::clone(&self.event_bus),
        )
    }
}

// Use case pattern
#[async_trait::async_trait]
pub trait UseCase<Input, Output> {
    async fn execute(&self, input: Input) -> Result<Output, UseCaseError>;
}

pub struct CreateUserUseCase {
    user_repository: Arc<dyn UserRepository>,
    event_bus: Arc<dyn EventBus>,
}

#[async_trait::async_trait]
impl UseCase<CreateUserRequest, CreateUserResponse> for CreateUserUseCase {
    async fn execute(&self, input: CreateUserRequest) -> Result<CreateUserResponse, UseCaseError> {
        // Validation
        let email = Email::new(input.email)?;

        // Business logic
        let user = User::new(input.name, email);

        // Persistence
        self.user_repository.save(&user).await?;

        // Events
        let event = UserCreatedEvent::new(&user);
        self.event_bus.publish(event).await?;

        Ok(CreateUserResponse::from(user))
    }
}

// Command Query Responsibility Segregation (CQRS)
pub trait Command {
    type Response;
}

pub trait Query {
    type Response;
}

#[derive(Debug)]
pub struct CreateUserCommand {
    pub name: String,
    pub email: String,
}

impl Command for CreateUserCommand {
    type Response = UserId;
}

#[derive(Debug)]
pub struct GetUserQuery {
    pub id: UserId,
}

impl Query for GetUserQuery {
    type Response = Option<User>;
}

#[async_trait::async_trait]
pub trait CommandHandler<C: Command> {
    async fn handle(&self, command: C) -> Result<C::Response, CommandError>;
}

#[async_trait::async_trait]
pub trait QueryHandler<Q: Query> {
    async fn handle(&self, query: Q) -> Result<Q::Response, QueryError>;
}

// Event sourcing pattern
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Event {
    pub id: EventId,
    pub aggregate_id: AggregateId,
    pub version: u64,
    pub event_type: String,
    pub data: serde_json::Value,
    pub timestamp: chrono::DateTime<chrono::Utc>,
}

pub struct EventStore {
    database: PgPool,
}

impl EventStore {
    pub async fn save_events(
        &self,
        aggregate_id: &AggregateId,
        expected_version: u64,
        events: &[Event],
    ) -> Result<(), EventStoreError> {
        let mut tx = self.database.begin().await?;

        // Optimistic concurrency check
        let current_version: Option<i64> = sqlx::query_scalar(
            "SELECT version FROM aggregates WHERE id = $1"
        )
        .bind(aggregate_id.to_string())
        .fetch_optional(&mut *tx)
        .await?;

        match current_version {
            Some(v) if v as u64 != expected_version => {
                return Err(EventStoreError::ConcurrencyConflict);
            }
            _ => {}
        }

        // Save events
        for event in events {
            sqlx::query!(
                r#"
                INSERT INTO events (id, aggregate_id, version, event_type, data, timestamp)
                VALUES ($1, $2, $3, $4, $5, $6)
                "#,
                event.id.to_string(),
                event.aggregate_id.to_string(),
                event.version as i64,
                event.event_type,
                event.data,
                event.timestamp
            )
            .execute(&mut *tx)
            .await?;
        }

        // Update aggregate version
        let new_version = expected_version + events.len() as u64;
        sqlx::query!(
            r#"
            INSERT INTO aggregates (id, version) VALUES ($1, $2)
            ON CONFLICT (id) DO UPDATE SET version = EXCLUDED.version
            "#,
            aggregate_id.to_string(),
            new_version as i64
        )
        .execute(&mut *tx)
        .await?;

        tx.commit().await?;
        Ok(())
    }

    pub async fn get_events(
        &self,
        aggregate_id: &AggregateId,
        from_version: u64,
    ) -> Result<Vec<Event>, EventStoreError> {
        let events = sqlx::query_as!(
            Event,
            r#"
            SELECT id as "id: EventId", aggregate_id as "aggregate_id: AggregateId",
                   version as "version!", event_type, data, timestamp
            FROM events
            WHERE aggregate_id = $1 AND version >= $2
            ORDER BY version
            "#,
            aggregate_id.to_string(),
            from_version as i64
        )
        .fetch_all(&self.database)
        .await?;

        Ok(events)
    }
}
```

### 🔄 State Machine Pattern

```rust
// Type-safe state machine
pub struct StateMachine<State> {
    state: State,
}

// States
pub struct Draft;
pub struct PendingReview;
pub struct Approved;
pub struct Published;
pub struct Rejected;

// Transitions
impl StateMachine<Draft> {
    pub fn new(content: String) -> Self {
        Self {
            state: Draft,
        }
    }

    pub fn submit_for_review(self) -> Result<StateMachine<PendingReview>, ValidationError> {
        // Validation logic
        if self.is_valid() {
            Ok(StateMachine {
                state: PendingReview,
            })
        } else {
            Err(ValidationError::InvalidContent)
        }
    }
}

impl StateMachine<PendingReview> {
    pub fn approve(self) -> StateMachine<Approved> {
        StateMachine {
            state: Approved,
        }
    }

    pub fn reject(self) -> StateMachine<Rejected> {
        StateMachine {
            state: Rejected,
        }
    }
}

impl StateMachine<Approved> {
    pub fn publish(self) -> StateMachine<Published> {
        StateMachine {
            state: Published,
        }
    }
}

impl StateMachine<Rejected> {
    pub fn revise(self) -> StateMachine<Draft> {
        StateMachine {
            state: Draft,
        }
    }
}

// Generic state machine for complex scenarios
#[derive(Debug, Clone)]
pub enum OrderState {
    Created,
    PaymentPending,
    PaymentConfirmed,
    Processing,
    Shipped,
    Delivered,
    Cancelled,
    Refunded,
}

#[derive(Debug, Clone)]
pub enum OrderEvent {
    PaymentInitiated,
    PaymentConfirmed,
    PaymentFailed,
    ProcessingStarted,
    Shipped,
    Delivered,
    CancelRequested,
    RefundProcessed,
}

pub struct OrderStateMachine;

impl OrderStateMachine {
    pub fn transition(
        current_state: &OrderState,
        event: &OrderEvent,
    ) -> Result<OrderState, StateMachineError> {
        use OrderState::*;
        use OrderEvent::*;

        match (current_state, event) {
            (Created, PaymentInitiated) => Ok(PaymentPending),
            (PaymentPending, PaymentConfirmed) => Ok(PaymentConfirmed),
            (PaymentPending, PaymentFailed) => Ok(Cancelled),
            (PaymentConfirmed, ProcessingStarted) => Ok(Processing),
            (Processing, Shipped) => Ok(Shipped),
            (Shipped, Delivered) => Ok(Delivered),

            // Cancellation paths
            (Created | PaymentPending, CancelRequested) => Ok(Cancelled),
            (PaymentConfirmed | Processing, CancelRequested) => Ok(Cancelled),

            // Refund paths
            (Delivered, RefundProcessed) => Ok(Refunded),

            _ => Err(StateMachineError::InvalidTransition {
                from: current_state.clone(),
                event: event.clone(),
            }),
        }
    }

    pub fn can_transition(state: &OrderState, event: &OrderEvent) -> bool {
        Self::transition(state, event).is_ok()
    }
}
```

---

## ✅ Best Practices Checklist

### 🎯 Development Checklist

**🔒 Memory Safety**
- ✅ Use `&str` instead of `String` for parameters when possible
- ✅ Prefer borrowing over cloning unless ownership transfer is needed
- ✅ Use `Arc<Mutex<T>>` for shared mutable state across threads
- ✅ Implement `Drop` for custom resource management
- ✅ Use `Box<dyn Trait>` for dynamic dispatch when appropriate

**⚡ Performance**
- ✅ Profile before optimizing - use `cargo bench` and flamegraphs
- ✅ Pre-allocate collections with `Vec::with_capacity()` when size is known
- ✅ Use `&[T]` instead of `Vec<T>` for parameters
- ✅ Consider `SmallVec` for stack-allocated small vectors
- ✅ Use `lazy_static!` or `once_cell` for expensive static computations

**🧪 Testing**
- ✅ Write unit tests for all public functions
- ✅ Use property-based testing with `proptest` for complex logic
- ✅ Mock external dependencies in tests
- ✅ Test error conditions, not just happy paths
- ✅ Use integration tests for end-to-end scenarios

**🔧 Error Handling**
- ✅ Use custom error types with `thiserror` for domain errors
- ✅ Prefer `Result<T, E>` over panicking
- ✅ Use `anyhow` for application-level error handling
- ✅ Provide context with `.context()` for debugging
- ✅ Handle all `Result` types (don't ignore with `let _ = ...`)

**📦 API Design**
- ✅ Make APIs hard to misuse (use type system for validation)
- ✅ Provide builder patterns for complex configuration
- ✅ Use newtypes for domain-specific values
- ✅ Document all public APIs with examples
- ✅ Follow naming conventions (`snake_case` for functions/variables)

**🔀 Concurrency**
- ✅ Use `tokio` for async I/O operations
- ✅ Prefer message passing (channels) over shared state
- ✅ Use structured concurrency patterns
- ✅ Implement proper cancellation handling
- ✅ Avoid blocking operations in async contexts

**🏗️ Architecture**
- ✅ Separate business logic from I/O operations
- ✅ Use dependency injection for testability
- ✅ Follow domain-driven design principles
- ✅ Implement proper logging and observability
- ✅ Design for failure - implement circuit breakers and retries

**📋 Code Quality**
- ✅ Run `clippy` and fix all warnings
- ✅ Format code with `rustfmt`
- ✅ Use meaningful variable and function names
- ✅ Keep functions small and focused
- ✅ Document complex algorithms and business logic

### 🚀 Production Checklist

**🔒 Security**
- ✅ Validate all inputs at API boundaries
- ✅ Use secure defaults for configurations
- ✅ Implement proper authentication and authorization
- ✅ Don't log sensitive information
- ✅ Use TLS for all network communications

**📊 Monitoring**
- ✅ Implement structured logging with `tracing`
- ✅ Add metrics for key business operations
- ✅ Set up health check endpoints
- ✅ Monitor resource usage (CPU, memory, disk)
- ✅ Implement distributed tracing for microservices

**🔧 Configuration**
- ✅ Use environment variables for configuration
- ✅ Implement configuration validation at startup
- ✅ Provide sensible defaults
- ✅ Support configuration hot reloading when needed
- ✅ Document all configuration options

**🚀 Deployment**
- ✅ Use multi-stage Docker builds for smaller images
- ✅ Run as non-root user in containers
- ✅ Implement graceful shutdown handling
- ✅ Use health checks in orchestration platforms
- ✅ Implement zero-downtime deployments

**🔄 Reliability**
- ✅ Implement circuit breakers for external services
- ✅ Add retry logic with exponential backoff
- ✅ Handle network timeouts appropriately
- ✅ Implement bulkheading for resource isolation
- ✅ Design for idempotency in API operations

---

*This comprehensive Rust guide covers the essential patterns, practices, and techniques for building robust, performant, and maintainable Rust applications. Keep this as your reference for mastering systems programming with Rust.*